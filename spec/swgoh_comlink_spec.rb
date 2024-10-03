# frozen_string_literal: true

require 'spec_helper'

describe SwgohComlink do
  context 'when provided comlink url is different' do
    it 'requires a comlink url' do
      expect { SwgohComlink.new }.to raise_error(ArgumentError)
    end

    it 'should handle URLs whether or not they included "https://"' do
      expect(SwgohComlink.new('test.com').comlink_url).to eq('https://test.com')
      expect(SwgohComlink.new('https://test.com').comlink_url).to eq('https://test.com')
    end
  end

  context 'when secret and access keys are not provided' do
    comlink = SwgohComlink.new('test.com')
    it 'can be instantiated without hmac validation' do
      expect(comlink.hmac_enabled).to eq(false)
    end
  end

  context 'when secret and access keys are provided' do
    comlink = SwgohComlink.new('url', { 'access_key' => 'ak', 'secret_key' => 'sk' })
    it 'can be instantiated with hmac validation' do
      expect(comlink.hmac_enabled).to eq(true)
    end

    it 'can use a symbol or a string to access keys' do
      expect(SwgohComlink.new('url', { 'access_key' => 'ak', secret_key: 'sk' }).hmac_enabled).to eq(true)
    end
  end

  context 'when invalid keys are provided' do
    it 'throws an error if one key is missing' do
      expect { SwgohComlink.new('url', { 'access_key' => 'b' }) }.to raise_error(ArgumentError, 'Secret key missing')
      expect { SwgohComlink.new('url', { 'secret_key' => 'b' }) }.to raise_error(ArgumentError, 'Access key missing')
    end
  end

  context 'when valid requests are made' do
    # swgohcomlink.com stubs out to the fake server, do not change
    comlink = SwgohComlink.new('swgohcomlink.com')
    it 'can retrieve enums' do
      expect(comlink.enums).to have_key('AbilityButtonLocationType')
    end
  end
end
