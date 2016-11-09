require "pp"

class BuyingBehavior
  attr_reader :expression, :variables

  # Initialize with parameters passed
  def initialize(items, settings)
    @items = items
    @settings = settings
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
    prime_items = @items.select {|item| item["prime"] == true }
    prime_item = prime_items.min_by {|item| item["price"] }
    if prime_item.nil?
      buy_cheap
    else
      prime_item
    end
  end

  def buy_expensive
    @items.max_by {|item| item["price"] }
  end
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
