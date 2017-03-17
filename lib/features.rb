class Features
  def initialize
  end

  def determine(feature, market_situation, evaluated_item)
    filtered_market_situation = market_situation.select { |item| item['product_id'] == evaluated_item['product_id'] }      # only evalute offers for same product id
    @cleaned_market_situation = filtered_market_situation.select { |item| item['offer_id'] != evaluated_item['offer_id'] } # exclude one offers

    case feature
    when 'static'
      self.class.feature_static
    when 'price_rank'
      self.class.feature_price_rank(market_situation, evaluated_item)
    when 'distance_to_cheapest_competitor'
      self.class.feature_distance_to_cheapest_competitor(market_situation, evaluated_item)
    when 'amount_of_all_competitors'
      self.class.feature_amount_of_all_competitors(market_situation)
    when 'average_price_on_market'
      self.class.feature_average_price_on_market(market_situation, evaluated_item)
    when 'quality_rank'
      self.class.feature_quality_rank(market_situation, evaluated_item)
    else
      puts "unsupported feature #{feature}" if $debug
      0
    end
  end

  private

  def self.feature_static
    1
  end

  def self.feature_price_rank(market_situation, evaluated_item)
    amount_of_cheaper_offers = market_situation.select { |item| item['price'] < evaluated_item['price'] }
    amount_of_cheaper_offers.size
  end

  def self.feature_distance_to_cheapest_competitor(market_situation, evaluated_item)
    sorted_market_situation = market_situation.sort_by(&:price)
    sorted_market_situation.last - evaluated_item['price']
  end

  def self.feature_amount_of_all_competitors(market_situation)
    market_situation.size
  end

  def self.feature_average_price_on_market(market_situation, evaluated_item)
    average_price = 0.0
    market_situation.select { |item| average_price += item['price'] }
    (average_price + evaluated_item['price']) / market_situation.size + 1
  end

  def self.feature_quality_rank(market_situation, evaluated_item)
    amount_of_better_quality_offers = market_situation.select { |item| item['quality'] > evaluated_item['quality'] }
    amount_of_better_quality_offers.size
  end
end
