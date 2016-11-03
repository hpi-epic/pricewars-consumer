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
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
