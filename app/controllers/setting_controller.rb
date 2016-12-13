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
  def init
    @timeout_if_no_offers_available = 2 # to be an integer
    @timeout_as_tick                = 1 # to be an integer
    @min_buying_amount              = 1
    @max_buying_amount              = 1
  end

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)
    init

    $list_of_threads ||= []
    params[:amount_of_consumers].times do
      thread = Thread.new do |_t|
        loop do
          sleep(@timeout_as_tick)
          available_items = get_available_items(params[:marketplace_url])
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
    render(nothing: true, status: 200) && return
  end

  private

  def get_available_items(marketplace_url)
    url = marketplace_url + "/offers"
    puts url
    HTTParty.get(url).body
    # '[{"offer_id":1,"product_id":"1","seller_id":"1","amount":3,"price":5,"shipping_time":5,"prime":true},{"offer_id":2,"product_id":"1","seller_id":"1","amount":3,"price":5,"shipping_time":5,"prime":true}]'
  end

  def logic(items, settings, _bulk_boolean)
    settings.key?("consumer_id") ? consumer_id = settings[:consumer_id] : consumer_id = 0

    if rand(1..100) < settings[:probability_of_sell] 
      settings[:behaviors].each do |behavior| # decide on buying behavior based on settings
        if rand(1..100) < behavior[:amount] # spread buying behavior accordingly to settings
          item = BuyingBehavior.new(items, settings).send("buy_" + behavior[:name]) # get item based on buying behavior
          # Thread.new do |_subT|
          status = execute(settings[:marketplace_url], item, consumer_id) # buy now!
          puts status
          # handle 409 or 410
          # end
          break
        else
          next
        end
      end
    end
  end

  def execute(marketplace_url, item, consumer_id)
    url = marketplace_url + "/offers/" + item["offer_id"].to_s + "/buy"
    puts url
    response = HTTParty.post(url,
                             body:    {price:       item["price"],
                                       amount:      rand(@min_buying_amount..@max_buying_amount),
                                       consumer_id: consumer_id,
                                       prime:       item["prime"]
                                      }.to_json,
                             headers: {"Content-Type" => "application/json"})
    response.code
  end
end
