module RegisterHelper
  def register_on(marketplace_url, consumer_url, name, description)
    unregister if $consumer_token.present?
    $marketplace_url = marketplace_url
    $consumer_name = name
    $consumer_description = description
    url = $marketplace_url + '/consumers'
    puts url if $debug
    response = HTTParty.post(url,
                             body:    { api_endpoint_url: consumer_url,
                                        consumer_name:    $consumer_name,
                                        description:      $consumer_description
                             }.to_json,
                             headers: { 'Content-Type' => 'application/json' })
    data = JSON.parse(response.body)
    $consumer_token = data['consumer_token']
    $consumer_id = data['consumer_id']
    puts "assigning new token #{$consumer_token} with #{response.code}" if $debug
    $consumer_id
  end

  def unregister
    return 404 if $consumer_id.blank? || $consumer_token.blank?

    url = $marketplace_url + '/consumers/' + $consumer_id
    puts url if $debug
    response = HTTParty.delete(url,
                               body:    {}.to_json,
                               headers: { 'Content-Type'  => 'application/json',
                                          'Authorization' => "Token #{$consumer_token}"
                               })
    puts "deregistered with status code #{response.code}" if $debug
    $consumer_token = nil
    $consumer_id = nil
    response.code
  end
end
