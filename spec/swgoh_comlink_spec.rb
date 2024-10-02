# frozen_string_literal: true

require 'spec_helper'

describe SwgohComlink do
  it 'requires a comlink url' do
    expect { SwgohComlink.new }.to raise_error(ArgumentError)
  end

  context 'when secret and access keys are not provided' do
    comlink = SwgohComlink.new('url')
    it 'can be instantiated without hmac validation' do
      expect(comlink.hmac_enabled).to eq(false)
    end
  end

  context 'when secret and access keys are provided' do
    comlink = SwgohComlink.new('url', { 'access_key' => 'ak', 'secret_key' => 'sk' })
    it 'can be instantiated without hmac validation' do
      expect(comlink.hmac_enabled).to eq(true)
    end
  end

  context 'when invalid keys are provided' do
    it 'throws an error if one key is missing' do
      expect { SwgohComlink.new('url', { 'access_key' => 'b' }) }.to raise_error(ArgumentError, 'Secret key missing')
      expect { SwgohComlink.new('url', { 'secret_key' => 'b' }) }.to raise_error(ArgumentError, 'Access key missing')
    end
  end
end
