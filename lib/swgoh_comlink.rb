# frozen_string_literal: true

require 'openssl'
require 'digest'
require 'json'
require 'net/http'
require 'uri'

require 'pry'

# Base class for the gem, a wrapper for Comlink
# See https://github.com/swgoh-utils/swgoh-comlink for more info on Comlink
class SwgohComlink
  attr_accessor :hmac_enabled, :comlink_url

  def initialize(comlink_url, keys = {})
    @comlink_url = comlink_url.start_with?('http') ? comlink_url : "https://#{comlink_url}"
    @hmac_enabled = false
    return if keys.empty?

    @secret_key = keys['secret_key'] || keys[:secret_key]
    @access_key = keys['access_key'] || keys[:access_key]

    raise ArgumentError, 'Secret key missing' unless @secret_key
    raise ArgumentError, 'Access key missing' unless @access_key

    @hmac_enabled = true
  end

  def enums
    path = '/enums'
    uri = URI.parse("#{@comlink_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    JSON.parse(http.request(request).body)
  end
end
