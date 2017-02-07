require "rails_helper"

RSpec.describe BehaviorController, type: :controller do
  describe "GET #behavior" do
    before do
      get :index
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "response with JSON body containing expected behavior attributes" do
      hash_body = JSON.parse(response.body)
      # expect { hash_body = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
      expect(hash_body).to match_array([{"name" => "first", "description" => "I am buying the first possible item", "amount" => 10},
                                        {"name" => "random", "description" => "I am buying random items", "amount" => 10},
                                        {"name" => "cheap", "description" => "I am buying the cheapest item", "amount" => 10},
                                        {"name" => "expensive", "description" => "I am buying the most expensive item", "amount" => 10},
                                        {"name" => "cheap_and_prime", "description" => "I am buying the cheapest item which supports prime shipping", "amount" => 10},
                                        {"name" => "cheapest_best_quality_with_prime", "description" => "I am buying the cheapest best quality available which supports prime.", "amount" => 10},
                                        {"name" => "cheapest_best_quality", "description" => "I am buying the cheapest best quality available.", "amount" => 10},
                                        {"name" => "second_cheap", "description" => "I am buying the second cheapest item", "amount" => 10},
                                        {"name" => "third_cheap", "description" => "I am buying the third cheapest item", "amount" => 10},
                                        {"name" => "sigmoid_distribution_price", "description" => "I am with sigmoid distribution on the price regarding the producer prices", "amount" => 10}])
    end
  end
end
