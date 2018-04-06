require 'pp'
require 'gaussian'
require 'sigmoid'
require 'logit'
require 'features'
# require 'statsample-glm'

class BuyingBehavior
  attr_reader :expression, :variables

  # Initialize with parameters passed
  def initialize(items, behavior_settings)
    $products           = items.map { |item| item['product_id'] }
    $unfiltered_items   = items
    @behavior_settings  = behavior_settings

    # uncomment to select a random product for evaluation rather based on product popularity
    # OPTIONS: select_random_product | select_based_on_product_popularity
    select_based_on_product_popularity

    puts "available items in buyingbehavior: #{$items.size}" if $debug
  end

  def buy_first
    validate_max_price($items.first)
  end

  def buy_random
    validate_max_price($items.sample)
  end

  def buy_cheap
    validate_max_price($items.min_by { |item| item['price'] })
  end

  def buy_n_cheap(n)
    n.times do
      item = buy_cheap
      return nil if item.nil?
      $items.delete(item)
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
    validate_max_price(having_prime($items).min_by { |item| item['price'] })
  end

  def buy_expensive
    validate_max_price($items.max_by { |item| item['price'] })
  end

  def buy_cheapest_best_quality_with_prime
    $items = having_prime($items)
    buy_cheapest_best_quality
  end

  def buy_cheapest_best_quality
    best_quality = $items.map { |item| item['quality'] }.max
    best_quality_items = $items.select { |item| item['quality'] == best_quality }
    validate_max_price(best_quality_items.min_by { |item| item['price'] })
  end

  def buy_sigmoid_distribution_price
    highest_prob    = 0
    highest_prob_item = {}

    $items.shuffle.each do |item|
      product = (@behavior_settings[:producer_prices].select { |product| product['uid'] == item['uid'] }).first
      if product.nil?
        puts "ERROR: item uid #{item['uid']} is unknown to producer_prices for sigmoid distribution"
        next
      end
      sig = RandomSigmoid.new(product['price'].to_i * 2, item['price'].to_i).rand

      prob = (sig * 100)

      if prob > highest_prob
        highest_prob      = prob
        highest_prob_item = item
      end
    end
    validate_max_price(highest_prob_item)
  end

  def buy_logit_coefficients
    theta             = @behavior_settings['coefficients'].map { |_key, value| value }
    highest_prob_item = {}
    highest_prob      = 0
    probs             = []

    $items.each do |item|
      names             = @behavior_settings['coefficients'].map { |key, _value| key }
      names.delete('intercept')
      features          = [build_features_array(names, item)]
      logit             = Logit.new
      y                 = []
      features.length.times { y.push(1) }

      prob              = logit.predict(features, theta, y)
      # glm = Statsample::GLM.compute data_set, :y, :logistic, {constant: 1, algorithm: :mle}

      probs.push(prob)
    end

    if $debug
      logit_model = Hash.new
      for i in (0..probs.length-1)
        break if probs.nil?
        log_item = $items[i]
        log_item["probability_of_sell"] = probs[i]
        logit_model[$items[i]["offer_id"]] = log_item
      end
      logit_model["global"] = {}
      logit_model["global"]["amount_of_all_competitors"] = $items.length
      logit_model["global"]["highest_prob_price_rank"] = 1 + $items.select { |item| item['price'] < $items[probs.index(probs.max)]['price'] }.size
      Logit.info logit_model.to_json
    end

    validate_max_price(normalize_and_roll_dice_with(probs))
  end

  def buy_prefer_cheap
    relevant_offers = $items.select{|item| item['price'] <= @behavior_settings['max_buying_price']}
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
      result.push(Features.new.determine(feature, $items, item))
    end
    result
  end

  def select_based_on_product_popularity
    if @behavior_settings['product_popularity'].nil?
      puts 'ALERT: product_popularity wrong configured, falling back to select_random_product'
      return select_random_product
    end
    products_in_marketsituation = $unfiltered_items.map { |item| item['product_id'] }
    supported_products = @behavior_settings['product_popularity'].select { |key, _value| products_in_marketsituation.uniq.include?(key.to_i) }
    $items = $unfiltered_items.select { |item| item['product_id'] == choose_weighted(supported_products).to_i }
  end

  def select_random_product
    $items = $unfiltered_items.select { |item| item['product_id'] == $products.uniq.sample }
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
        selected_item = $items[i]
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
    target = rand(sum)
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

  def finding_best_quality(items)
    items.map { |item| item['quality'] }.max
  end
end

class InvalidExpressionError < RuntimeError; end
class LimitExceededError < RuntimeError; end
