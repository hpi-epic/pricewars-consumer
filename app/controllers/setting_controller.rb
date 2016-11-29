require "pp"
require "buyingbehavior"
require "net/http"
#require 'resolv'
require "resolv-replace"

class SettingController < ApplicationController
  include HTTParty
  persistent_connection_adapter name:         "Marketplace",
                                pool_size:    300,
                                idle_timeout: 10,
                                keep_alive:   30

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)

    if params.key?("test")
      available_items = get_available_items(params[:marketplace_url])
      status = logic(available_items, params, params.key?("bulk") ? true : false)
    else
      # Thread.new do |_t|
      loop do
        sleep(1)
        available_items = get_available_items(params[:marketplace_url])
        if available_items == "[]"
          sleep(2)
          next
        end
        status = logic(JSON.parse(available_items), params, params.key?("bulk") ? true : false)
      end
      # end

    end
    render(nothing: true, status: 200) && return
  end

  def delete
    # TODO: kill open threads
    render(nothing: true, status: 200) && return
  end

  private

  def get_available_items(marketplace_url)
    url = marketplace_url + "/offers"
    puts url
    HTTParty.get(url).body
    #'[{"offer_id":1,"product_id":"1","seller_id":"1","amount":3,"price":5,"shipping_time":5,"prime":true},{"offer_id":2,"product_id":"1","seller_id":"1","amount":3,"price":5,"shipping_time":5,"prime":true}]'
  end

  def logic(items, settings, _bulk_boolean)
    settings.key?("consumer_id") ? consumer_id = settings[:consumer_id] : consumer_id = 0
    sells = settings[:amount_of_consumers] / settings[:probability_of_sell] * 100 # calculate actual sells with regards to #consumers and selling probability
    sells = 1 if sells < 1 # if there are less than 1 sell, set it to 1 to avoid errors

    sells.round.times do # for each sell in this iteration, execute
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
      :body => { :price => item["price"],
                 :amount => rand(1...2),
                 :consumer_id => consumer_id,
                 :prime => item["prime"]
               }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    response.code
  end
end
