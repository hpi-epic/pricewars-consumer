require "rails_helper"

RSpec.describe RegisterController, type: :controller do
  describe "POST #register", type: :request do
    before do
      post_response = '{"consumer_id":1337}'
      stub_request(:post, /marketplace.api.mp_pricewars.com/).to_return(body: post_response, status: 200, headers: {})
    end

    before do
      params = {
        marketplace_url: "http://marketplace.api.mp_pricewars.com",
        consumer_url:    "http://consumer.api.mp_pricewars.com",
        name:            "consumer 1",
        description:     "Major consumer buying random"
      }
      post "/register", params.to_json, "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end
