require "pp"
# require 'httparty-icebox'
require "gaussian"
require "sigmoid"
require "logit"

class BuyingBehavior
  # include HTTParty::Icebox
  include HTTParty
  attr_reader :expression, :variables

  # cache :store => 'file', :timeout => 300, :location => '/tmp/'

  # Initialize with parameters passed
  def initialize(items, behavior_settings)
    products           = items.map {|item| item["product_id"] }
    @items             = items

    # uncomment to select a random product for evaluation rather based on product popularity
    # OPTIONS: select_random_product | select_based_on_product_popularity
    select_based_on_product_popularity

    @behavior_settings = behavior_settings
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
      sig = RandomSigmoid.new(@behavior_settings.producer_prices[item["uid"]] * 2, item["price"]).rand
      prob = (sig * 100).ceil
      if prob > highest_prob
        highest_prob      = prob
        highest_prob_item = item
      end
    end

    validate_max_price(highest_prob_item)
  end

  def buy_logit_coefficients
    logit = Logit.new()
  end

  private

  def select_based_on_product_popularity
    product_id = choose_weighted(@behavior_settings.product_popularity)
    @items = @items.select {|item| item["product_id"] == product_id }
  end

  def select_random_product
    @items = @items.select {|item| item["product_id"] == products.uniq.sample }
  end

  # consumes { :black => 51, :white => 17 }
  def choose_weighted(weighted)
	  sum = weighted.inject(0) do |sum, item_and_weight|
	    sum += item_and_weight[1]
	  end
	  target = rand(sum)
	  weighted.each do |item, weight|
	    return item if target <= weight
	    target -= weight
	  end
	end

  def validate_max_price(item)
    return nil if item.nil? || item.blank?
    if item["price"] > @behavior_settings.max_buying_price
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
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
