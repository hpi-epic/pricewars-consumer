require "net/http"
# require 'resolv'
require "resolv-replace"

module PartyHelper
  include HTTParty

  persistent_connection_adapter name:         "Marketplace",
                                pool_size:    300,
                                idle_timeout: 10,
                                keep_alive:   30

  def http_get_on(url)
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

  def http_post_on(url, header, body)
    puts url if $debug
    begin
      result = HTTParty.post(url, body: body, headers: header)
    rescue => e
      puts "Critical: HTTP POST on #{url} with header: #{header} and body: #{body} resulted in #{e}, lets wait 10s"
      sleep(10)
      result = nil
    end
    result
  end

end
