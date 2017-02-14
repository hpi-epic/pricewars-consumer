class Features
  def initialize(feature, market_situation, evaluated_item)
    filtered_market_situation = market_situation.select {|item| item["product_id"] != evaluated_item["product_id"] }      # only evalute offers for same product id
    @market_situation         = filtered_market_situation.select {|item| item["offer_id"] != evaluated_item["offer_id"] } #exclude one offers
    @evaluated_item           = evaluated_item

    case feature
    when "static"
      self.class.feature_static
    when "price_rank"
      self.feature_price_rank
    when "distance_to_cheapest_competitor"
      self.feature_distance_to_cheapest_competitor
    when "amount_of_all_competitors"
      self.feature_amount_of_all_competitors
    when "average_price_on_market"
      self.feature_average_price_on_market
    when "quality_rank"
      self.feature_quality_rank
    else
      puts "unsupported feature #{feature}"
      0
    end
  end

  private

  def self.feature_static
    1
  end

  def self.feature_price_rank
    amount_of_cheaper_offers = @market_situation.select {|item| item["price"] < evaluated_item["price"] }
    amount_of_cheaper_offers.size
  end

  def self.feature_distance_to_cheapest_competitor
    sorted_market_situation = @market_situation.sort_by(&:price)
    sorted_market_situation.last - evaluated_item["price"]
  end

  def self.feature_amount_of_all_competitors
    @market_situation.size
  end

  def self.feature_average_price_on_market
    average_price = 0.0
    @market_situation.select {|item| average_price += item["price"] }
    (average_price + evaluated_item["price"]) / @market_situation.size+1
  end

  def self.feature_quality_rank
    amount_of_better_quality_offers = @market_situation.select {|item| item["quality"] > evaluated_item["quality"] }
    amount_of_better_quality_offers.size
  end
end
