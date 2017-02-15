require "rails_helper"

RSpec.describe BehaviorController, type: :controller do
  describe "GET #behavior" do
    before do
      get :index
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    xit "response with JSON body containing expected behavior attributes" do
      hash_body = JSON.parse(response.body)
      # expect { hash_body = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
      expect(hash_body).to match_array([{"name" => "first", "description" => "I am buying the first possible item", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "random", "description" => "I am buying random items", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "cheap", "description" => "I am buying the cheapest item", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "expensive", "description" => "I am buying the most expensive item", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "cheap_and_prime", "description" => "I am buying the cheapest item which supports prime shipping", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "cheapest_best_quality_with_prime", "description" => "I am buying the cheapest best quality available which supports prime.", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "cheapest_best_quality", "description" => "I am buying the cheapest best quality available.", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "second_cheap", "description" => "I am buying the second cheapest item", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "third_cheap", "description" => "I am buying the third cheapest item", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "sigmoid_distribution_price", "description" => "I am with sigmoid distribution on the price regarding the producer prices", "settings" => {}, "settings_description" => "Behavior settings not necessary", "amount" => 9},
                                        {"name" => "logit_coefficients", "description" => "I am with logit coefficients", "settings" => {}, "settings_description" => "Key Value map for Feature and their coeffient", "amount" => 9}])
    end
  end
end
