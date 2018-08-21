require 'pp'
require 'buyingbehavior'
require 'behavior_controller'

class SettingController < BehaviorController
  include RegisterHelper
  include PartyHelper

  $threads = []
  $min_buying_amount = 1
  $max_buying_amount = 1
  $consumer_per_minute = 100.0
  $timeout_if_too_many_requests = 30
  $max_buying_price = 80
  $debug = false
  $behaviors_settings = BehaviorController.gather_available_behaviors

  def update_settings(params)
    $min_buying_amount = params[:min_buying_amount] if params.key?(:min_buying_amount)
    $max_buying_amount = params[:max_buying_amount] if params.key?(:max_buying_amount)
    $consumer_per_minute = [params[:consumer_per_minute], 0.01].max if params.key?(:consumer_per_minute)
    $timeout_if_too_many_requests = params[:timeout_if_too_many_requests] if params.key?(:timeout_if_too_many_requests)
    $max_buying_price = params[:max_buying_price] if params.key?(:max_buying_price)
    $debug = params[:debug] if params.key?(:debug)
    $behaviors_settings = params[:behaviors] if params.key?(:behaviors)
    $marketplace_url = params[:marketplace_url] if params.key?(:marketplace_url)
  end

  def index
    render json: retrieve_settings
  end

  def update
    render(nothing: true, status: 405) && return unless request.content_type == 'application/json'
    update_settings(params)
    render json: retrieve_settings
  end

  def create
    render(nothing: true, status: 405) && return unless request.content_type == 'application/json'
    render(nothing: true, status: 405) && return unless params.key?(:marketplace_url)

    stop_threads
    update_settings(params)
    register_with_marketplace unless $consumer_token.present?

    thread = Thread.new do |_t|
      next_customer_time = Time.now
      # Use a random generator with a fixed seed to have comparable waiting times over multiple simulations.
      random_generator = Random.new(17)
      loop do
        begin
          visit_marketplace
        rescue RateLimitExceeded
          puts "Rate limit exceeded. Wait #{$timeout_if_too_many_requests} seconds"
          next_customer_time += $timeout_if_too_many_requests
        end
        next_customer_time += exponential(60.0 / $consumer_per_minute, random_generator)
        sleep([0, next_customer_time - Time.now].max)
      end
    end
    if $debug
      thread.abort_on_exception = true
    end
    $threads.push(thread)

    render json: retrieve_settings
  end

  def status
    result = {}
    result['status'] = $threads.empty? ? 'dead' : 'running'
    render json: result
  end

  def delete
    if $threads.empty?
      render(text: 'no instance running', status: 200) && return
    end

    stop_threads

    if $marketplace_url.nil? || $consumer_id.nil?
      render(text: 'invalid configuration: consumer_id or marketplace_url unknown', status: 417)
    else
      render(text: 'all process instances terminated', status: 200)
    end
  end

  private

  def register_with_marketplace
    register_on($marketplace_url, request.base_url, 'Default', 'Buying with specified settings')
  end

  def deregister_with_marketplace
    unregister
  end

  def get_available_items
    url = $marketplace_url + '/offers'
    begin
      response = PartyHelper.http_get_on(url)
    end while response.nil?
    puts response.code if $debug
    JSON.parse(response.body)
  end

  def stop_threads
    $threads.each do |thread|
      thread.kill
    end
    $threads.clear
  end

  def visit_marketplace
    item, behavior_name = buying_decision
    return if item.nil?
    status = buy(item, behavior_name)
    if status == 401
      puts '401..' if $debug
      deregister_with_marketplace
      register_with_marketplace
      puts 'ERROR: marketplace rejected consumer API Token'
    end
  end

  def buying_decision
    items = get_available_items
    puts "processing #{items.size} offers" if $debug
    return if !items.any? || items.empty?
    behavior_weights = {}
    $behaviors_settings.each { |behavior| behavior_weights[behavior[:name]] = behavior[:amount] }
    selected_behavior = choose_weighted(behavior_weights)
    puts "selected_behavior: #{selected_behavior}" if $debug
    behavior = ($behaviors_settings.select { |b| b[:name] == selected_behavior }).first
    puts "actual behavior: #{behavior[:name]}" if $debug
    # get item based on buying behavior
    return BuyingBehavior.new(items, expand_behavior_settings(behavior[:settings])).send('buy_' + behavior[:name]), behavior[:name]
  end

  def buy(item, behavior_name)
    url = $marketplace_url + '/offers/' + item['offer_id'].to_s + '/buy'
    puts "buying #{item['offer_id']} for #{behavior_name} with quality #{item['quality']}" if $debug

    body = { price:       item['price'],
             amount:      rand($min_buying_amount..$max_buying_amount),
             consumer_id: $consumer_id,
             prime:       item['prime'],
             behavior:    behavior_name
             }.to_json
    header = {'Content-Type' => 'application/json',
              Authorization: "Token #{$consumer_token}"}

    response = PartyHelper.http_post_on(url, header, body)
    if response.nil?
      nil
    else
      puts response.code if $debug
      response.code
    end
  end

  def expand_behavior_settings(settings)
    settings[:max_buying_price]   = $max_buying_price
    settings
  end

  def retrieve_settings
    {
        min_buying_amount: $min_buying_amount,
        max_buying_amount: $max_buying_amount,
        consumer_per_minute: $consumer_per_minute,
        behaviors: $behaviors_settings,
        timeout_if_too_many_requests: $timeout_if_too_many_requests,
        max_buying_price: $max_buying_price,
        debug: $debug,
        marketplace_url: $marketplace_url,
    }
  end

  def choose_weighted(weighted)
    sum = weighted.inject(0) do |sum, item_and_weight|
      sum + item_and_weight[1]
    end
    target = rand(sum)
    weighted.each do |item, weight|
      return item if target <= weight
      target -= weight
    end
  end

  # Samples a random number from the exponential distribution
  # This function is from: https://stackoverflow.com/a/18304464
  def exponential(mean, generator)
    -mean * Math.log(generator.rand) if mean > 0
  end

end
