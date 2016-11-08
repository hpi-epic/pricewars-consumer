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
      expect(hash_body).to match_array([{"name" => "first", "description" => "I am buying the first possible item"},
                                        {"name" => "random", "description" => "I am buying random items"},
                                        {"name" => "cheap", "description" => "I am buying the cheapest item"},
                                        {"name" => "expensive", "description" => "I am buying the most expensive item"},
                                        {"name" => "cheap_and_prime", "description" => "I am buying the cheapest item which supports prime shipping"}])
    end
  end
end
