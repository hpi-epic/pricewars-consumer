class BehaviorController < ApplicationController
  def index
    result = []
    result.push(select_first_behavior)
    result.push(select_random_behavior)
    result.push(select_cheap_behavior)
    result.push(select_expensive_behavior)
    result.push(select_cheap_and_prime_behavior)
    render json: result
  end

  private

  def select_first_behavior
    behavior = {}
    behavior["name"] = "first"
    behavior["description"] = "I am buying the first possible item"
    behavior
  end

  def select_random_behavior
    behavior = {}
    behavior["name"] = "random"
    behavior["description"] = "I am buying random items"
    behavior
  end

  def select_cheap_behavior
    behavior = {}
    behavior["name"] = "cheap"
    behavior["description"] = "I am buying the cheapest item"
    behavior
  end

  def select_expensive_behavior
    behavior = {}
    behavior["name"] = "expensive"
    behavior["description"] = "I am buying the most expensive item"
    behavior
  end

  def select_cheap_and_prime_behavior
    behavior = {}
    behavior["name"] = "cheap_and_prime"
    behavior["description"] = "I am buying the cheapest item which supports prime shipping"
    behavior
  end
end
