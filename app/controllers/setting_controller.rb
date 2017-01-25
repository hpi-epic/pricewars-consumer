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
    @min_buying_amount              = params.key?(:min_buying_amount)              ? params[:min_buying_amount]              : 1
    @max_buying_amount              = params.key?(:max_buying_amount)              ? params[:max_buying_amount]              : 1
    @min_wait                       = params.key?(:min_wait)                       ? params[:min_wait]                       : 0.1
    @max_wait                       = params.key?(:max_wait)                       ? params[:max_wait]                       : 2
    @timeout_if_no_offers_available = params.key?(:timeout_if_no_offers_available) ? params[:timeout_if_no_offers_available] : 2
    @consumer_per_minute            = params.key?(:consumer_per_minute)           ? params[:consumer_per_minute]            : 100.0
    @max_req_per_sec                = params.key?(:max_req_per_sec)                ? params[:max_req_per_sec]                : 10
    @timeout_if_too_many_requests   = params.key?(:timeout_if_too_many_requests)   ? params[:timeout_if_too_many_requests]   : 30
    @amount_of_consumers            = params.key?(:amount_of_consumers)            ? params[:amount_of_consumers]            : 1
    @probability_of_sell            = params.key?(:probability_of_sell)            ? params[:probability_of_sell]            : 100
    @behaviors_settings             = params.key?(:behaviors)                      ? params[:behaviors]                      : gather_available_behaviors
    $marketplace_url                = params[:marketplace_url]
    @consumer_url                   = request.original_url
  end

  def index
    settings = {}
    settings["consumer_per_minute "]           = @consumer_per_minute            ? @consumer_per_minute            : 100.0
    settings["max_req_per_sec"]                = @max_req_per_sec                ? @max_req_per_sec                : 10
    settings["marketplace_url"]                = $marketplace_url                ? $marketplace_url                : "http://vm-mpws2016hp1-04.eaalab.hpi.uni-potsdam.de:8080/marketplace"
    settings["amount_of_consumers"]            = @amount_of_consumers            ? @amount_of_consumers            : 1
    settings["probability_of_sell"]            = @probability_of_sell            ? @probability_of_sell            : 100
    settings["min_buying_amount"]              = @min_buying_amount              ? @min_buying_amount              : 1
    settings["max_buying_amount"]              = @max_buying_amount              ? @max_buying_amount              : 1
    settings["min_wait"]                       = @min_wait                       ? @min_wait                       : 0.1
    settings["max_wait"]                       = @max_wait                       ? @max_wait                       : 2
    settings["behaviors"]                      = @behaviors_settings             ? @behaviors_settings             : gather_available_behaviors
    settings["timeout_if_no_offers_available"] = @timeout_if_no_offers_available ? @timeout_if_no_offers_available : 2
    settings["timeout_if_too_many_requests"]   = @timeout_if_too_many_requests   ? @timeout_if_too_many_requests   : 30
    render json: settings
  end

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)

    init(params, request)
    register_with_marketplace

    $list_of_threads ||= []
    @amount_of_consumers.times do
      thread = Thread.new do |_t|
        loop do
          sleep((@consumer_per_minute / 60) + rand(@min_wait..@max_wait)) # sleep regarding global time zone and random offset
          available_items = get_available_items
          if available_items == "[]"
            sleep(@timeout_if_no_offers_available)
            next
          end
          status = logic(JSON.parse(available_items), params, params.key?("bulk") ? true : false)
        end
      end
      $list_of_threads.push(thread)
    end

    render(nothing: true, status: 200) && return
  end

  def delete
    if $list_of_threads.present?
      $list_of_threads.each do |thread|
        Thread.kill(thread)
      end
      $list_of_threads = []
    end
    deregister_with_marketplace
    render(nothing: true, status: 200) && return
  end

  private

  def register_with_marketplace
    url = $marketplace_url + "/consumers"
    puts url
    response = HTTParty.post(url,
                             body:    {api_endpoint_url: @consumer_url,
                                       consumer_name:    "Consumer",
                                       description:      "Cool"
                                      }.to_json,
                             headers: {"Content-Type" => "application/json"})
    data = JSON.parse(response.body)
    @consumer_token = data["consumer_token"]
    $consumer_id    = data["consumer_id"]
  end

  def deregister_with_marketplace
    url = $marketplace_url + "/consumer/" + $consumer_id
    response = HTTParty.delete(url,
                               body:    {}.to_json,
                               headers: {"Content-Type"  => "application/json",
                                         "Authorization" => "Token #{@consumer_token}"
                                })
  end

  def get_available_items
    url = $marketplace_url + "/offers"
    puts url
    HTTParty.get(url).body
  end

  def logic(items, settings, _bulk_boolean)
    if rand(1..100) < @probability_of_sell
      @behaviors_settings.each do |behavior| # decide on buying behavior based on settings
        if rand(1..100) < behavior[:amount]  # spread buying behavior accordingly to settings
          item = BuyingBehavior.new(items, settings).send("buy_" + behavior[:name]) # get item based on buying behavior
          puts item
          # Thread.new do |_subT|
          status = execute(item, behavior[:name]) # buy now!
          puts status
          if status == 429
            sleep(@timeout_if_too_many_requests)
          elsif status == 401
            register_with_marketplace
          end
          # end
          break
        else
          next
        end
      end
    end
  end

  def execute(item, behavior)
    url = $marketplace_url + "/offers/" + item["offer_id"].to_s + "/buy"
    puts url
    response = HTTParty.post(url,
                             body:    {price:       item["price"],
                                       amount:      rand(@min_buying_amount..@max_buying_amount),
                                       consumer_id: $consumer_id,
                                       prime:       item["prime"],
                                       behavior:    behavior
                                      }.to_json,
                             headers: {"Content-Type"  => "application/json",
                                       "Authorization" => "Token #{@consumer_token}"
                                      })
    response.code
  end
end
