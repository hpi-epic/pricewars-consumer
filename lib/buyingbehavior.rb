require "pp"

class BuyingBehavior
  attr_reader :expression, :variables

  # Initialize with parameters passed
  def initialize(items, settings)
    products        = items.map {|item| item["product_id"] }
    @items          = items.select {|item| item["product_id"] == products.uniq.sample }
    @settings       = settings
  end

  def buy_first
    @items.first
  end

  def buy_random
    @items.sample
  end

  def buy_cheap
    @items.min_by {|item| item["price"] }
  end

  def buy_cheap_and_prime
    prime_item = having_prime(@items).min_by {|item| item["price"] }
    if prime_item.nil?
      buy_cheap
    else
      prime_item
    end
  end

  def buy_expensive
    @items.max_by {|item| item["price"] }
  end

  def buy_cheapest_best_quality_with_prime
    @items = having_prime(@items)
    buy_cheapest_best_quality
  end

  def buy_cheapest_best_quality
    best_quality = @items.map {|item| item["quality"] }.max
    best_quality_items = @items.select {|item| item["quality"] == best_quality }
    cheapest_best_quality_item = best_quality_items.min_by {|item| item["price"] }
    if cheapest_best_quality_item.nil?
      buy_cheap
    else
      cheapest_best_quality_item
    end
  end

  private

  def having_prime(items)
    items.select {|item| item["prime"] == true }
  end

  def finding_best_quality(items)
    items.map {|item| item["quality"] }.max
  end
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
