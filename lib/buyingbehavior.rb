require "pp"

class BuyingBehavior
  attr_reader :expression, :variables

  # Initialize with parameters passed
  def initialize(items, max_buying_price)
    products           = items.map {|item| item["product_id"] }
    @items             = items.select {|item| item["product_id"] == products.uniq.sample }
    @max_buying_price  = max_buying_price
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

  private

  def validate_max_price(item)
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
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
