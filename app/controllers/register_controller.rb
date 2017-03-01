class RegisterController < ApplicationController
  include RegisterHelper

  def create
    render(nothing: true, status: 405) && return unless request.content_type == "application/json"
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)
    render(nothing: true, status: 405) && return unless params.key?(:consumer_url)
    render(nothing: true, status: 405) && return unless params.key?(:name)
    render(nothing: true, status: 405) && return unless params.key?(:description)

    customer = {}
    customer["id"] = register_on(params[:marketplace_url], params[:consumer_url], params[:name], params[:description])
    render json: customer
  end

  def delete
    if $list_of_threads.present?
      $list_of_threads.each do |thread|
        Thread.kill(thread)
      end
      $list_of_threads = []
    end

    response_code = unregister
    render json: {'status code from marketplace': response_code}.as_json
  end
end
