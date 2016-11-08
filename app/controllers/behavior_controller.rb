class BehaviorController < ApplicationController
  def index
    result = []
    result.push(select_first_behavior)
    result.push(select_random_behavior)
    result.push(select_cheap_behavior)
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
    behavior["description"] = "I am buying the cheaptest item"
    behavior
  end
end
