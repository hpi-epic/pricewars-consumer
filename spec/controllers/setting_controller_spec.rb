require "rails_helper"
require "pp"

RSpec.describe SettingController, type: :controller do
  describe "GET #settings", type: :request do
    before do
      get_response =  '[{"quality":1,"price":22.50,"amount":11,"offer_id":4407,"product_id":1,"uid":11,"merchant_id":"ddq6bUP+/Etxboc8OVC8B3QQxO8+Ca5e4kqYOChwNN4=","shipping_time":{"standard":5,"prime":1},"prime":true},'\
                       '{"quality":2,"price":51.00,"amount":5,"offer_id":4467,"product_id":1,"uid":12,"merchant_id":"/CWsWojD9goF9R11o37j2C+2IXQojHRWAYEcXFyKiDo=","shipping_time":{"standard":1,"prime":1},"prime":true},'\
                       '{"quality":1,"price":54.00,"amount":51,"offer_id":4457,"product_id":1,"uid":11,"merchant_id":"/CWsWojD9goF9R11o37j2C+2IXQojHRWAYEcXFyKiDo=","shipping_time":{"standard":1,"prime":1},"prime":true},'\
                       '{"quality":2,"price":51.00,"amount":15,"offer_id":4461,"product_id":1,"uid":12,"merchant_id":"/CWsWojD9goF9R11o37j2C+2IXQojHRWAYEcXFyKiDo=","shipping_time":{"standard":1,"prime":1},"prime":true},'\
                       '{"quality":3,"price":54.00,"amount":52,"offer_id":4465,"product_id":1,"uid":11,"merchant_id":"/CWsWojD9goF9R11o37j2C+2IXQojHRWAYEcXFyKiDo=","shipping_time":{"standard":1,"prime":1},"prime":true},'\
                       '{"quality":4,"price":54.00,"amount":60,"offer_id":4491,"product_id":1,"uid":11,"merchant_id":"/CWsWojD9goF9R11o37j2C+2IXQojHRWAYEcXFyKiDo=","shipping_time":{"standard":1,"prime":1},"prime":true},'\
                       '{"quality":3,"price":54.00,"amount":64,"offer_id":4468,"product_id":1,"uid":11,"merchant_id":"/CWsWojD9goF9R11o37j2C+2IXQojHRWAYEcXFyKiDo=","shipping_time":{"standard":1,"prime":1},"prime":true},'\
                       '{"quality":1,"price":22.50,"amount":21,"offer_id":4548,"product_id":1,"uid":11,"merchant_id":"ddq6bUP+/Etxboc8OVC8B3QQxO8+Ca5e4kqYOChwNN4=","shipping_time":{"standard":5,"prime":1},"prime":true},'\
                       '{"quality":4,"price":22.50,"amount":11,"offer_id":4569,"product_id":1,"uid":11,"merchant_id":"ddq6bUP+/Etxboc8OVC8B3QQxO8+Ca5e4kqYOChwNN4=","shipping_time":{"standard":5,"prime":1},"prime":true},'\
                       '{"quality":1,"price":29.99,"amount":1,"offer_id":5696,"product_id":1,"uid":11,"merchant_id":"MpWsNBYFvUgqq+rI0FGDTPYJ/RLB9ED7KLmIQwGqzAk=","shipping_time":{"standard":5,"prime":1},"prime":true},'\
                       '{"quality":2,"price":29.99,"amount":1,"offer_id":5695,"product_id":1,"uid":11,"merchant_id":"MpWsNBYFvUgqq+rI0FGDTPYJ/RLB9ED7KLmIQwGqzAk=","shipping_time":{"standard":5,"prime":1},"prime":true}]'

      stub_request(:get, /marketplace.api.mp_pricewars.com/).to_return(body: get_response, status: 200, headers: {})
      post_response = "{}"
      stub_request(:post, /marketplace.api.mp_pricewars.com/).to_return(body: post_response, status: 200, headers: {})
    end

    before do
      @params = {tick:                1,
                marketplace_url:     "http://marketplace.api.mp_pricewars.com",
                amount_of_consumers: 1,
                probability_of_sell: 100,
                behaviors:           [
                  {type:   "first",
                   amount: 100}
                ],
                test:                true
      }
    end

    xit "returns http success" do
      post "/setting/", @params.to_json, "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"
      expect(response).to have_http_status(:success)
    end

    xit "behavior first" do
      @params["behaviors"]["type"] = "first"
      post "/setting/", @params.to_json, "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"
      expect(response).to have_http_status(:success)
    end

    xit "behavior cheap" do
      @params["behaviors"]["type"] = "cheap"
      post "/setting/", @params.to_json, "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"
      expect(response).to have_http_status(:success)
    end
  end
end
