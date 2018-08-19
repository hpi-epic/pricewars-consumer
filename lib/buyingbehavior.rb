require 'pp'
require 'gaussian'
require 'logit'
require 'features'

class BuyingBehavior
  attr_reader :expression, :variables

  def initialize(items, behavior_settings)
    @items = items
    @behavior_settings = behavior_settings
    puts "available items in buying behavior: #{@items.size}" if $debug
  end

  def buy_first
    validate_max_price(@items.first)
  end

  def buy_random
    validate_max_price(@items.sample)
  end

  def buy_cheap
    validate_max_price(@items.min_by { |item| item['price'] })
  end

  def buy_n_cheap(n)
    n.times do
      item = buy_cheap
      return nil if item.nil?
      @items.delete(item)
    end
    buy_cheap
  end

  def buy_second_cheap
    buy_n_cheap(1)
  end

  def buy_third_cheap
    buy_n_cheap(2)
  end

  def buy_cheap_and_prime
    validate_max_price(having_prime(@items).min_by { |item| item['price'] })
  end

  def buy_expensive
    validate_max_price(@items.max_by { |item| item['price'] })
  end

  def buy_cheapest_best_quality_with_prime
    @items = having_prime(@items)
    buy_cheapest_best_quality
  end

  def buy_cheapest_best_quality
    best_quality = @items.map { |item| item['quality'] }.min
    best_quality_items = @items.select { |item| item['quality'] == best_quality }
    validate_max_price(best_quality_items.min_by { |item| item['price'] })
  end

  def buy_logit_coefficients
    theta             = @behavior_settings['coefficients'].map { |_key, value| value }
    probs             = []

    @items.each do |item|
      names             = @behavior_settings['coefficients'].map { |key, _value| key }
      names.delete('intercept')
      features          = [build_features_array(names, item)]
      logit             = Logit.new
      y                 = []
      features.length.times { y.push(1) }

      prob              = logit.predict(features, theta, y)

      probs.push(prob)
    end

    if $debug
      logit_model = Hash.new
      for i in (0..probs.length-1)
        break if probs.nil?
        log_item = @items[i]
        log_item["probability_of_sell"] = probs[i]
        logit_model[@items[i]["offer_id"]] = log_item
      end
      logit_model["global"] = {}
      logit_model["global"]["amount_of_all_competitors"] = @items.length
      logit_model["global"]["highest_prob_price_rank"] = 1 + @items.select { |item| item['price'] < @items[probs.index(probs.max)]['price'] }.size
      #Logit.info logit_model.to_json
    end

    validate_max_price(normalize_and_roll_dice_with(probs))
  end

  def buy_prefer_cheap
    relevant_offers = @items.select{|item| item['price'] <= @behavior_settings['max_buying_price']}
    if relevant_offers.length == 0
      nil
    else
      probabilites = buy_probabilities(relevant_offers)
      choose_weighted(relevant_offers.zip(probabilites))
    end
  end

  private

  # Uses a modified market power formula to calculate buying probabilities.
  # The cheapest offers has the highest probability.
  # The higher the price difference to the cheapest offers, the lower is the buying probability.
  def buy_probabilities(offers)
    price_sensitivity = 1
    prices = offers.map{|offer| offer['price']}
    max_price = prices.max
    price_sum = prices.reduce(0, :+)
    probabilities = []
    offers.each do |offer|
      probability = (max_price + price_sensitivity - offer['price']) / (offers.length * (max_price + price_sensitivity) - price_sum)
      probabilities.push(probability)
    end
    probabilities
  end

  def build_features_array(feature_names, item)
    result = []
    feature_names.each do |feature|
      result.push(Features.new.determine(feature, @items, item))
    end
    result
  end

  def normalize_and_roll_dice_with(probs)
    sumProbs = probs.inject(:+)
    return nil if sumProbs == 0
    normalized_probs = probs.map { |p| p / sumProbs }
    r = Random.rand
    currentSum = 0

    for i in (0..normalized_probs.length - 1)
      currentSum += normalized_probs[i]
      if r <= currentSum
        selected_item = @items[i]
        break
      end
    end

    selected_item
  end

  # consumes { :black => 51, :white => 17 }
  def choose_weighted(weighted)
    sum = weighted.inject(0) do |sum, item_and_weight|
      sum += item_and_weight[1]
    end
    target = Random.rand(sum)
    weighted.each do |item, weight|
      return item if target <= weight
      target -= weight
    end
  end

  def validate_max_price(item)
    return nil if item.nil? || item.blank?
    if item['price'] > @behavior_settings['max_buying_price']
      puts "item price (#{item['price']}€) is above max_buying_price (#{@behavior_settings['max_buying_price']}€), reject" if $debug
      nil
    else
      item
    end
  end

  def having_prime(items)
    items.select { |item| item['prime'] == true }
  end
end
