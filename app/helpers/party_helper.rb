require 'net/http'
# require 'resolv'
require 'resolv-replace'

module PartyHelper
  include HTTParty

  # uncomment for using caching for external calls (e.g. producer) to reduce waiting time
  # cache :store => 'file', :timeout => 300, :location => '/tmp/'

  persistent_connection_adapter name:         'Marketplace',
                                pool_size:    300,
                                idle_timeout: 10,
                                keep_alive:   30

  def self.http_get_on(url)
    puts url if $debug
    begin
      result = HTTParty.get(url)
    rescue => e
      puts "Critical: HTTP GET on #{url} resulted in #{e}, lets wait 10s"
      sleep(10)
      result = nil
    end
    result
  end

  def self.http_post_on(url, header, body)
    puts url if $debug
    begin
      response = HTTParty.post(url, body: body, headers: header)
    rescue => e
      puts "Critical: HTTP POST on #{url} with header: #{header} and body: #{body} resulted in #{e}"
      response = nil
    end
    raise RateLimitExceeded if response.code == 429
    response
  end
end

class RateLimitExceeded < StandardError
end