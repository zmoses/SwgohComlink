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
  attr_accessor :hmac_enabled

  def initialize(comlink_url, keys = {})
    @comlink_url = comlink_url
    @hmac_enabled = false
    return if keys.empty?

    @secret_key = keys['secret_key']
    @access_key = keys['access_key']

    raise ArgumentError, 'Secret key missing' unless @secret_key
    raise ArgumentError, 'Access key missing' unless @access_key

    @hmac_enabled = true
  end
end
