class BehaviorController < ApplicationController
  def index
    render json: BehaviorController.gather_available_behaviors
  end

  def self.gather_available_behaviors
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
    result.push(select_logit_coefficients)
    result.push(select_scoring_based)
  end

  private

  def self.select_cheapest_best_quality_with_prime_behavior
    behavior = {}
    behavior['name'] = 'cheapest_best_quality_with_prime'
    behavior['description'] = 'I am buying the cheapest best quality available which supports prime.'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_cheapest_best_quality_behavior
    behavior = {}
    behavior['name'] = 'cheapest_best_quality'
    behavior['description'] = 'I am buying the cheapest best quality available.'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_first_behavior
    behavior = {}
    behavior['name'] = 'first'
    behavior['description'] = 'I am buying the first possible item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_random_behavior
    behavior = {}
    behavior['name'] = 'random'
    behavior['description'] = 'I am buying random items'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_cheap_behavior
    behavior = {}
    behavior['name'] = 'cheap'
    behavior['description'] = 'I am buying the cheapest item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_second_cheap_behavior
    behavior = {}
    behavior['name'] = 'second_cheap'
    behavior['description'] = 'I am buying the second cheapest item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_third_cheap_behavior
    behavior = {}
    behavior['name'] = 'third_cheap'
    behavior['description'] = 'I am buying the third cheapest item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_expensive_behavior
    behavior = {}
    behavior['name'] = 'expensive'
    behavior['description'] = 'I am buying the most expensive item'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_cheap_and_prime_behavior
    behavior = {}
    behavior['name'] = 'cheap_and_prime'
    behavior['description'] = 'I am buying the cheapest item which supports prime shipping'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end

  def self.select_logit_coefficients
    behavior = {}
    behavior['name'] = 'logit_coefficients'
    behavior['description'] = 'I am with logit coefficients'
    behavior['settings'] = {coefficients:
                                {intercept: -6.6177961,
                                 price_rank: 0.2083944,
                                 amount_of_all_competitors: 0.253481,
                                 average_price_on_market: -0.0079326,
                                 quality_rank: -0.1835972}}
    behavior['settings_description'] = 'Key Value map for Feature and their coeffient'
    behavior['amount'] = 0
    behavior
  end

  def self.select_prefer_cheap
    behavior = {}
    behavior['name'] = 'prefer_cheap'
    behavior['description'] = 'I prefer cheap products but sometimes I allow me a more expensive product'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 100
    behavior
  end

  def self.select_scoring_based
    behavior = {}
    behavior['name'] = 'scoring_based'
    behavior['description'] = 'I consider price and quality with some factor in my buying decision. I won\'t buy the best offer if its score is above my willingness to buy.'
    behavior['settings'] = {}
    behavior['settings_description'] = 'Behavior settings not necessary'
    behavior['amount'] = 0
    behavior
  end
end
