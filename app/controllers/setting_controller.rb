require "pp"
require "buyingbehavior"
require "net/http"
# require 'resolv'
require "resolv-replace"

class SettingController < ApplicationController
  include HTTParty
  persistent_connection_adapter name:         "Marketplace",
                                pool_size:    300,
                                idle_timeout: 10,
                                keep_alive:   30
  def init(params)
    params.key?(:min_buying_amount)              ? (@min_buying_amount = params[:min_buying_amount]) : (@min_buying_amount = 1)
    params.key?(:max_buying_amount)              ? (@max_buying_amount = params[:max_buying_amount]) : (@max_buying_amount = 1)
    params.key?(:min_wait)                       ? (@min_wait = params[:min_wait])                   : (@min_wait = 0.1)
    params.key?(:max_wait)                       ? (@max_wait = params[:max_wait])                   : (@max_wait = 2)
    params.key?(:timeout_if_no_offers_available) ? (@timeout_if_no_offers_available = params[:timeout_if_no_offers_available]) : (@timeout_if_no_offers_available = 2)
    params.key?(:tick)                           ? (@tick = params[:tick])                           : (@tick = 100.0)
    params.key?(:max_req_per_sec)                ? (@max_req_per_sec = params[:max_req_per_sec])     : (@max_req_per_sec = 10)
    params.key?(:timeout_if_too_many_requests)   ? (@timeout_if_too_many_requests = params[:timeout_if_too_many_requests])     : (@timeout_if_too_many_requests = 30)
    @marketplace_url = params[:marketplace_url]
  end

  def sample
    settings = {}
    settings["tick"]                           = 10.0
    settings["max_req_per_sec"]                = 10
    settings["marketplace_url"]                = "http://172.16.58.6:8080"
    settings["amount_of_consumers"]            = 2
    settings["probability_of_sell"]            = 10
    settings["min_buying_amount"]              = 1
    settings["max_buying_amount"]              = 1
    settings["min_wait"]                       = 0.1
    settings["max_wait"]                       = 2
    settings["behaviors"]                      = []
    settings["timeout_if_no_offers_available"] = 2
    settings["timeout_if_too_many_requests"]   = 30
    render json: settings
  end

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)

    init(params)
    @consumer_url = request.original_url
    register_with_marketplace()

    $list_of_threads ||= []
    params[:amount_of_consumers].times do
      thread = Thread.new do |_t|
        loop do
          sleep((@tick / @max_req_per_sec) + (rand(@min_wait..@max_wait)/@tick)) #sleep regarding global time zone and random offset
          available_items = get_available_items()
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
    deregister_with_marketplace()
    render(nothing: true, status: 200) && return
  end

  private

  def register_with_marketplace()
    url = @marketplace_url +"/consumers"
    puts url
    response = HTTParty.post(url,
                             body:    {api_endpoint_url: @consumer_url,
                                       consumer_name: "Consumer",
                                       description: "Cool"
                                    }.to_json,
                             headers: {"Content-Type" => "application/json"})
    data = JSON.parse(response.body)
    @consumer_token = data["consumer_token"]
    @consumer_id    = data["consumer_id"]
  end

  def deregister_with_marketplace()
    url = @marketplace_url +"/consumer/"+@consumer_id
    response = HTTParty.delete(url,
                             body:    {}.to_json,
                             headers: {"Content-Type" => "application/json",
                                       "Authorization" => "Token #{@consumer_token}"
                              })
  end

  def get_available_items()
    url = @marketplace_url + "/offers"
    puts url
    HTTParty.get(url).body
  end

  def logic(items, settings, _bulk_boolean)
    settings.key?("consumer_id") ? consumer_id = settings[:consumer_id] : consumer_id = 0

    if rand(1..100) < settings[:probability_of_sell]
      settings[:behaviors].each do |behavior| # decide on buying behavior based on settings
        if rand(1..100) < behavior[:amount] # spread buying behavior accordingly to settings
          item = BuyingBehavior.new(items, settings).send("buy_" + behavior[:name]) # get item based on buying behavior
          # Thread.new do |_subT|
          status = execute(item, consumer_id) # buy now!
          puts status
          if status == 429
            sleep(@timeout_if_too_many_requests)
          elsif status == 401
             register_with_marketplace()
          end
          #end
          break
        else
          next
        end
      end
    end
  end

  def execute(item, consumer_id)
    url = @marketplace_url + "/offers/" + item["offer_id"].to_s + "/buy"
    puts url
    response = HTTParty.post(url,
                             body:    {price:       item["price"],
                                       amount:      rand(@min_buying_amount..@max_buying_amount),
                                       consumer_id: @consumer_id,
                                       prime:       item["prime"]
                                      }.to_json,
                             headers: {"Content-Type" => "application/json",
                                       "Authorization" => "Token #{@consumer_token}"
                                      })
    response.code
  end
end
