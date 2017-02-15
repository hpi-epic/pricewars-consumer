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
    result.push(select_sigmoid_distribution_price)
    #result.push(select_logit_coefficients)
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
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_cheapest_best_quality_behavior
    behavior = {}
    behavior["name"] = "cheapest_best_quality"
    behavior["description"] = "I am buying the cheapest best quality available."
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_first_behavior
    behavior = {}
    behavior["name"] = "first"
    behavior["description"] = "I am buying the first possible item"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_random_behavior
    behavior = {}
    behavior["name"] = "random"
    behavior["description"] = "I am buying random items"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_cheap_behavior
    behavior = {}
    behavior["name"] = "cheap"
    behavior["description"] = "I am buying the cheapest item"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_second_cheap_behavior
    behavior = {}
    behavior["name"] = "second_cheap"
    behavior["description"] = "I am buying the second cheapest item"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_third_cheap_behavior
    behavior = {}
    behavior["name"] = "third_cheap"
    behavior["description"] = "I am buying the third cheapest item"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_expensive_behavior
    behavior = {}
    behavior["name"] = "expensive"
    behavior["description"] = "I am buying the most expensive item"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_cheap_and_prime_behavior
    behavior = {}
    behavior["name"] = "cheap_and_prime"
    behavior["description"] = "I am buying the cheapest item which supports prime shipping"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_sigmoid_distribution_price
    behavior = {}
    behavior["name"] = "sigmoid_distribution_price"
    behavior["description"] = "I am with sigmoid distribution on the price regarding the producer prices"
    behavior["settings"] = {}
    behavior["settings_description"] = "Behavior settings not necessary"
    behavior
  end

  def select_logit_coefficients
    behavior = {}
    behavior["name"] = "logit_coefficients"
    behavior["description"] = "I am with logit coefficients"
    behavior["settings"] = {}
    behavior["settings_description"] = "Key Value map for Feature and their coeffient"
    behavior
  end
end
