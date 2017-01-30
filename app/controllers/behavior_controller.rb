class BehaviorController < ApplicationController
  def index
    render json: gather_available_behaviors
  end

  def gather_available_behaviors
    result = []
    result.push(select_first_behavior)
    result.push(select_random_behavior)
    result.push(select_cheap_behavior)
    result.push(select_expensive_behavior)
    result.push(select_cheap_and_prime_behavior)
    result.push(select_cheapest_best_quality_behavior)
    result.push(select_cheapest_best_quality_with_prime_behavior)
    result.push(select_second_cheap_behavior)
    result.push(select_third_cheap_behavior)
    evenly_distributed_behavior(result)
  end

  private

  def evenly_distributed_behavior(behaviors)
    result = []
    behaviors.each do |behavior|
      behavior["amount"] = 100 / behaviors.length
      result.push(behavior)
    end
    result
  end

  def select_cheapest_best_quality_with_prime_behavior
    behavior = {}
    behavior["name"] = "cheapest_best_quality_with_prime"
    behavior["description"] = "I am buying the cheapest best quality available which supports prime."
    behavior
  end

  def select_cheapest_best_quality_behavior
    behavior = {}
    behavior["name"] = "cheapest_best_quality"
    behavior["description"] = "I am buying the cheapest best quality available."
    behavior
  end

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

  def select_second_cheap_behavior
    behavior = {}
    behavior["name"] = "second_cheap"
    behavior["description"] = "I am buying the second cheapest item"
    behavior
  end

  def select_third_cheap_behavior
    behavior = {}
    behavior["name"] = "third_cheap"
    behavior["description"] = "I am buying the third cheapest item"
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
