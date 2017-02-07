require "pp"
# require 'httparty-icebox'
require "gaussian"
require "sigmoid"

class BuyingBehavior
  # include HTTParty::Icebox
  include HTTParty
  attr_reader :expression, :variables

  # cache :store => 'file', :timeout => 300, :location => '/tmp/'

  # Initialize with parameters passed
  def initialize(items, max_buying_price, producer_url)
    products           = items.map {|item| item["product_id"] }
    @items             = items.select {|item| item["product_id"] == products.uniq.sample }
    @max_buying_price  = max_buying_price
    @producter_prices  = retrieve_producter_prices(producer_url)
  end

  def buy_first
    validate_max_price(@items.first)
  end

  def buy_random
    validate_max_price(@items.sample)
  end

  def buy_cheap
    validate_max_price(@items.min_by {|item| item["price"] })
  end

  def buy_n_cheap(n)
    n.times do
      item = buy_cheap
      return nil if item.nil?
      @items.delete(item)
    end
    buy_cheap
  end

  def buy_second_cheap
    buy_n_cheap(1)
  end

  def buy_third_cheap
    buy_n_cheap(2)
  end

  def buy_cheap_and_prime
    validate_max_price(having_prime(@items).min_by {|item| item["price"] })
  end

  def buy_expensive
    validate_max_price(@items.max_by {|item| item["price"] })
  end

  def buy_cheapest_best_quality_with_prime
    @items = having_prime(@items)
    buy_cheapest_best_quality
  end

  def buy_cheapest_best_quality
    best_quality = @items.map {|item| item["quality"] }.max
    best_quality_items = @items.select {|item| item["quality"] == best_quality }
    validate_max_price(best_quality_items.min_by {|item| item["price"] })
  end

  def buy_sigmoid_distribution_price
    highest_prob    = 0
    highest_prob_item = {}

    @items.shuffle.each do |item|
      sig = RandomSigmoid.new(@producter_prices[item["uid"]] * 2, item["price"]).rand
      prob = (sig * 100).ceil
      puts "#{prob}% with sig #{sig} for #{item}"
      if prob > highest_prob
        highest_prob      = prob
        highest_prob_item = item
      end
    end

    validate_max_price(highest_prob_item)
  end

  private

  def validate_max_price(item)
    return nil if item.nil? || item.blank?
    if item["price"] > @max_buying_price
      nil
    else
      item
    end
  end

  def having_prime(items)
    items.select {|item| item["prime"] == true }
  end

  def finding_best_quality(items)
    items.map {|item| item["quality"] }.max
  end

  def retrieve_producter_prices(producer_url)
    results = {}
    products_details = HTTParty.get(producer_url + "/products")
    products_details.each do |product|
      results[product["uid"]] = product["price"]
    end
    results
  end
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
