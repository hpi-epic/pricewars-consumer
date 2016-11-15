class RegisterController < ApplicationController

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)
    render(nothing: true, status: 405) && return unless params.key?(:consumer_url)
    render(nothing: true, status: 405) && return unless params.key?(:name)
    render(nothing: true, status: 405) && return unless params.key?(:description)

    customer = Hash.new
    customer["id"] = register_on(params[:marketplace_url], params[:consumer_url], params[:name], params[:description])
    render json: customer
  end

  private

  def register_on(marketplace_url, consumer_url, name, description)

    url = marketplace_url + "/customer/register"
    HTTParty.post(url,
      :body => { :customer_url => consumer_url,
                 :name => name,
                 :description => description
               }.to_json,
      :headers => { 'Content-Type' => 'application/json' } ).body
  end
end
