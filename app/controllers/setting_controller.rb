require "pp"
require "buyingbehavior"
require 'net/http'

class SettingController < ApplicationController
  include HTTParty
  persistent_connection_adapter :name => 'Marketplace',
                                :pool_size => 200,
                                :idle_timeout => 10,
                                :keep_alive => 30

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)

    if params.key?("test")
      available_items = get_available_items(params[:marketplace_url])
      status = logic(available_items, params, params.key?("bulk") ? true : false)
    else
      #Thread.new do |_t|
        loop do
          available_items = get_available_items(params[:marketplace_url])
          status = logic(available_items, params, params.key?("bulk") ? true : false)
          #sleep(1)
        end
      #end

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
    response = HTTParty.get(url)
    JSON.parse(response.body)
  end

  def logic(items, settings, _bulk_boolean)
    sells = settings[:amount_of_consumers] / settings[:probability_of_sell] * 100
    sells = 1 if sells < 1
    puts "running #{sells.round} times"
    sells.round.times do
      item = BuyingBehavior.new(items, settings).buy_random
      #item = BuyingBehavior.new(items, settings).buy_cheap
      #Thread.new do |_subT|
        execute(params[:marketplace_url], item)
      #end
    end
  end

  def execute(marketplace_url, item)
    url = marketplace_url + "/offers/" + item["offer_id"].to_s + "/buy"
    puts url
    response = HTTParty.post(url)
    response.code
  end
end
