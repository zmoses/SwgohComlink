require 'openssl'
require 'digest'
require 'json'
require 'net/http'
require 'uri'

class ComlinkApiRequest
  attr_accessor :hmac_enabled, :comlink_url

  def initialize(comlink_url, keys)
    @comlink_url = comlink_url.start_with?('http') ? comlink_url : "https://#{comlink_url}"
    @hmac_enabled = false
    return if keys.empty?

    @secret_key = keys['secret_key'] || keys[:secret_key]
    @access_key = keys['access_key'] || keys[:access_key]

    raise ArgumentError, 'Secret key missing' unless @secret_key
    raise ArgumentError, 'Access key missing' unless @access_key

    @hmac_enabled = true
  end

  def get(path)
    uri = URI.parse("#{@comlink_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    http.request(request).body
  end

  def post(path, body)
    uri = URI.parse("#{@comlink_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    add_hmac_headers(request, 'POST', path, body)
    request.body = body

    http.request(request).body
  end

  private

  def add_hmac_headers(request, type, endpoint, payload = '')
    return unless @hmac_enabled

    req_time = (Time.now.to_i * 1000).to_s

    payload_hash_digest = Digest::MD5.hexdigest(payload)

    hmac_obj = OpenSSL::HMAC.new(@secret_key, OpenSSL::Digest.new('sha256'))
    hmac_obj.update(req_time + type + endpoint + payload_hash_digest)

    request['X-Date'] = req_time
    request['Authorization'] = "HMAC-SHA256 Credential=#{@access_key},Signature=#{hmac_obj.hexdigest}"
  end
end