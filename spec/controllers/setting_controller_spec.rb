require "rails_helper"
require "pp"

RSpec.describe SettingController, type: :controller do
  describe "GET #settings", type: :request do
    before do
      get_response =  '[{"offer_id":1,"product_id":"1","seller_id":"1","amount":3,"price":5,"shipping_time":5,"prime":true},'+
                       '{"offer_id":1,"product_id":"1","seller_id":"1","amount":3,"price":5,"shipping_time":5,"prime":true}]'
      stub_request(:get, /marketplace.api.mp_pricewars.com/).to_return(body: get_response, status: 200, headers: {})
      post_response = "{}"
      stub_request(:post, /marketplace.api.mp_pricewars.com/).to_return(body: post_response, status: 200, headers: {})
    end

    before do
      params = {tick:                1,
                marketplace_url:     "http://marketplace.api.mp_pricewars.com",
                amount_of_consumers: 10,
                probability_of_sell: 33,
                behaviors:           [
                  {type:   "first",
                   amount: 10}
                ],
                test:                true
      }
      post "/setting/?test=true", params.to_json, "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end
