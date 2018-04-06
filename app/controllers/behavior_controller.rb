class BehaviorController < ApplicationController
  def index
    render json: gather_available_behaviors
  end

  def gather_available_behaviors
    result = []
    result.push(select_prefer_cheap)
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
    result.push(select_logit_coefficients)
    first_behavior_activated(result)
  end

  private

  def first_behavior_activated(behaviors)
    behaviors_with_amount = behaviors.map{|behavior| behavior.merge({'amount' => 0})}
    behaviors_with_amount.first['amount'] = 100
    behaviors_with_amount
  end

  def evenly_distributed_behavior(behaviors)
    result = []
    behaviors.each do |behavior|
      behavior['amount'] = 100 / behaviors.length
      result.push(behavior)
    end
    result
  end

  def select_cheapest_best_quality_with_prime_behavior
    behavior = {}
    behavior['name'] = 'cheapest_best_quality_with_prime'
    behavior['description'] = 'I am buying the cheapest best quality available which supports prime.'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_cheapest_best_quality_behavior
    behavior = {}
    behavior['name'] = 'cheapest_best_quality'
    behavior['description'] = 'I am buying the cheapest best quality available.'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_first_behavior
    behavior = {}
    behavior['name'] = 'first'
    behavior['description'] = 'I am buying the first possible item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_random_behavior
    behavior = {}
    behavior['name'] = 'random'
    behavior['description'] = 'I am buying random items'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_cheap_behavior
    behavior = {}
    behavior['name'] = 'cheap'
    behavior['description'] = 'I am buying the cheapest item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_second_cheap_behavior
    behavior = {}
    behavior['name'] = 'second_cheap'
    behavior['description'] = 'I am buying the second cheapest item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_third_cheap_behavior
    behavior = {}
    behavior['name'] = 'third_cheap'
    behavior['description'] = 'I am buying the third cheapest item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_expensive_behavior
    behavior = {}
    behavior['name'] = 'expensive'
    behavior['description'] = 'I am buying the most expensive item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_cheap_and_prime_behavior
    behavior = {}
    behavior['name'] = 'cheap_and_prime'
    behavior['description'] = 'I am buying the cheapest item which supports prime shipping'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_sigmoid_distribution_price
    behavior = {}
    behavior['name'] = 'sigmoid_distribution_price'
    behavior['description'] = 'I am with sigmoid distribution on the price regarding the producer prices'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end

  def select_logit_coefficients
    behavior = {}
    behavior['name'] = 'logit_coefficients'
    behavior['description'] = 'I am with logit coefficients'
    behavior['settings'] = { "coefficients": { "intercept": -6.6177961, "price_rank": 0.2083944, "amount_of_all_competitors": 0.253481, "average_price_on_market": -0.0079326, "quality_rank": -0.1835972 } }
    behavior['settings_description'] = 'Key Value map for Feature and their coeffient'
    behavior
  end

  def select_prefer_cheap
    behavior = {}
    behavior['name'] = 'prefer_cheap'
    behavior['description'] = 'I prefer cheap products but sometimes I allow me a more expensive product'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior
  end
end
