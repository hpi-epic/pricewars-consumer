require "pp"
require "buyingbehavior"
require "net/http"
# require 'resolv'
require "resolv-replace"
require "behavior_controller"

class SettingController < BehaviorController
  include HTTParty

  persistent_connection_adapter name:         "Marketplace",
                                pool_size:    300,
                                idle_timeout: 10,
                                keep_alive:   30

  def init(params, request)
    $min_buying_amount              = params.key?(:min_buying_amount)              ? params[:min_buying_amount]              : 1
    $max_buying_amount              = params.key?(:max_buying_amount)              ? params[:max_buying_amount]              : 1
    $min_wait                       = params.key?(:min_wait)                       ? params[:min_wait]                       : 0.1
    $max_wait                       = params.key?(:max_wait)                       ? params[:max_wait]                       : 2
    $timeout_if_no_offers_available = params.key?(:timeout_if_no_offers_available) ? params[:timeout_if_no_offers_available] : 2
    $consumer_per_minute            = params.key?(:consumer_per_minute)            ? params[:consumer_per_minute]            : 100.0
    $timeout_if_too_many_requests   = params.key?(:timeout_if_too_many_requests)   ? params[:timeout_if_too_many_requests]   : 30
    $amount_of_consumers            = params.key?(:amount_of_consumers)            ? params[:amount_of_consumers]            : 1
    $probability_of_buy             = params.key?(:probability_of_buy)             ? params[:probability_of_buy]             : 100
    $max_buying_price               = params.key?(:max_buying_price)               ? params[:max_buying_price]               : 80
    $debug                          = params.key?(:debug)                          ? params[:debug]                          : true
    $behaviors_settings             = params.key?(:behaviors)                      ? params[:behaviors]                      : gather_available_behaviors
    $producer_url                   = params.key?(:producer_url)                   ? params[:producer_url]                   : $producer_url
    $product_popularity             = params.key?(:product_popularity)             ? params[:product_popularity]             : retrieve_and_build_product_popularity
    $marketplace_url                = params[:marketplace_url]
    $consumer_url                   = request.base_url

    normalize_product_popularity
  end

  def index
    render json: retrieve_current_or_default_settings
  end

  def update
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)
    init(params, request)
    render json: retrieve_current_or_default_settings
  end

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)

    init(params, request)
    register_with_marketplace

    $list_of_threads ||= []
    $amount_of_consumers.times do
      thread = Thread.new do |_t|
        loop do
          general_timeout_through_consumer_settings = (60 / $consumer_per_minute) + rand($min_wait..$max_wait)
          puts "next iteration starting of with sleeping #{general_timeout_through_consumer_settings}s" if $debug
          sleep(general_timeout_through_consumer_settings) # sleep regarding global time zone and random offset
          available_items = get_available_items
          if available_items == "[]"
            puts "no items available, sleeping #{$timeout_if_no_offers_available}s" if $debug
            sleep($timeout_if_no_offers_available)
            next
          end
          status = logic(JSON.parse(available_items), params, params.key?("bulk") ? true : false)
        end
      end
      $list_of_threads.push(thread)
    end

    render json: retrieve_current_or_default_settings
  end

  def status
    result = {}
    result["status"] = $list_of_threads.present? ? "running" : "dead"
    render json: result
  end

  def delete
    if $list_of_threads.present?
      $list_of_threads.each do |thread|
        Thread.kill(thread)
      end
      $list_of_threads = []
      deregister_with_marketplace
      unless $marketplace_url.nil? || $consumer_id.nil?
        render(nothing: true, status: 200) && return
      else
        render(text: "invalid configuration: consumer_id or marketplace_url unknown", status: 404) && return
      end
    else
      render(text: "no instance running", status: 404) && return
    end
  end

  private

  def register_with_marketplace
    url = $marketplace_url + "/consumers"
    puts url if $debug
    response = HTTParty.post(url,
                             body:    {api_endpoint_url: $consumer_url,
                                       consumer_name:    "Default",
                                       description:      "Buying with specified settings"
                                      }.to_json,
                             headers: {"Content-Type" => "application/json"})
    data = JSON.parse(response.body)
    $consumer_token = data["consumer_token"]
    $consumer_id    = data["consumer_id"]
    puts "assigning new token #{$consumer_token}" if $debug
  end

  def deregister_with_marketplace
    url = $marketplace_url + "/consumer/" + $consumer_id
    puts url if $debug
    response = HTTParty.delete(url,
                               body:    {}.to_json,
                               headers: {"Content-Type"  => "application/json",
                                         "Authorization" => "Token #{$consumer_token}"
                                })
    puts "deregistered with status code #{response.code}" if $debug
    response
  end

  def get_available_items
    url = $marketplace_url + "/offers"
    puts url if $debug
    response = HTTParty.get(url)
    puts response.code if $debug
    response.body
  end

  def logic(items, _settings, _bulk_boolean)
    if rand(1..100) < $probability_of_buy
      $behaviors_settings.each do |behavior| # decide on buying behavior based on settings
        if rand(1..100) < behavior[:amount]  # spread buying behavior accordingly to settings
          item = BuyingBehavior.new(items, expand_behavior_settings(behavior.settings)).send("buy_" + behavior[:name]) # get item based on buying behavior
          if item.nil?
            puts "no item selected by BuyingBehavior, sleeping #{$timeout_if_no_offers_available}s" if $debug
            sleep($timeout_if_no_offers_available)
            break
          end
          # Thread.new do |_subT|
          status = execute(item, behavior[:name]) # buy now!
          if status == 429
            puts "429, sleeping #{$timeout_if_too_many_requests}s" if $debug
            sleep($timeout_if_too_many_requests)
          elsif status == 401
            puts "401.." if $debug
            deregister_with_marketplace
            register_with_marketplace
          end
          # end
          break
        else
          puts "The luck is not with us, maybe next round" if $debug
          next
        end
      end
    else
      puts "luck did not strike for our buy" if $debug
    end
  end

  def execute(item, behavior)
    url = $marketplace_url + "/offers/" + item["offer_id"].to_s + "/buy"
    puts url if $debug
    response = HTTParty.post(url,
                             body:    {price:       item["price"],
                                       amount:      rand($min_buying_amount..$max_buying_amount),
                                       consumer_id: $consumer_id,
                                       prime:       item["prime"],
                                       behavior:    behavior
                                      }.to_json,
                             headers: {"Content-Type"  => "application/json",
                                       "Authorization" => "Token #{$consumer_token}"
                                      })
    puts response.code if $debug
    response.code
  end

  def expand_behavior_settings(settings)
    settings.producer_prices    = $producer_details
    settings.max_buying_price   = $max_buying_price
    settings.product_popularity = $product_popularity
    settings
  end

  def retrieve_and_build_product_popularity
    results = {}
    $producer_details = HTTParty.get($producer_url + "/products").map {|item| item["product_id"] }
    $producer_details.each do |product|
      results[product] = 100.0 / products_details.length
    end
    results
  end

  def normalize_product_popularity
    total = 0.0
    $product_popularity.each do |_key, value|
      total = total + value
    end
    $product_popularity.each do |key2, value2|
      $product_popularity[key2] = (value2/total*100).ceil
    end
  end

  def retrieve_current_or_default_settings
    settings = {}
    settings["consumer_per_minute"]            = $consumer_per_minute            ? $consumer_per_minute            : 100.0
    settings["amount_of_consumers"]            = $amount_of_consumers            ? $amount_of_consumers            : 1
    settings["probability_of_buy"]             = $probability_of_buy             ? $probability_of_buy             : 100
    settings["min_buying_amount"]              = $min_buying_amount              ? $min_buying_amount              : 1
    settings["max_buying_amount"]              = $max_buying_amount              ? $max_buying_amount              : 1
    settings["min_wait"]                       = $min_wait                       ? $min_wait                       : 0.1
    settings["max_wait"]                       = $max_wait                       ? $max_wait                       : 2
    settings["behaviors"]                      = $behaviors_settings             ? $behaviors_settings             : gather_available_behaviors
    settings["timeout_if_no_offers_available"] = $timeout_if_no_offers_available ? $timeout_if_no_offers_available : 2
    settings["timeout_if_too_many_requests"]   = $timeout_if_too_many_requests   ? $timeout_if_too_many_requests   : 30
    settings["max_buying_price"]               = $max_buying_price               ? $max_buying_price               : 80
    settings["debug"]                          = $debug                          ? $debug                          : true
    settings["product_popularity"]             = $product_popularity             ? $product_popularity             : retrieve_and_build_product_popularity
    settings["producer_url"]                   = $producer_url
    settings["marketplace_url"]                = $marketplace_url
    settings
  end
end
