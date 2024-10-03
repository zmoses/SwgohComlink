# frozen_string_literal: true

require 'spec_helper'

describe ComlinkApiRequest do
  context 'when provided comlink url is different' do
    it 'requires a comlink url' do
      expect { ComlinkApiRequest.new }.to raise_error(ArgumentError)
    end

    it 'should handle URLs whether or not they included "https://"' do
      expect(ComlinkApiRequest.new('test.com', {}).comlink_url).to eq('https://test.com')
      expect(ComlinkApiRequest.new('https://test.com', {}).comlink_url).to eq('https://test.com')
    end
  end

  context 'when secret and access keys are not provided' do
    comlink = ComlinkApiRequest.new('test.com', {})
    it 'can be instantiated without hmac validation' do
      expect(comlink.hmac_enabled).to eq(false)
    end
  end

  context 'when secret and access keys are provided' do
    comlink = ComlinkApiRequest.new('url', { 'access_key' => 'ak', 'secret_key' => 'sk' })
    it 'can be instantiated with hmac validation' do
      expect(comlink.hmac_enabled).to eq(true)
    end

    it 'can use a symbol or a string to access keys' do
      expect(ComlinkApiRequest.new('url', { 'access_key' => 'ak', secret_key: 'sk' }).hmac_enabled).to eq(true)
    end
  end

  context 'when invalid keys are provided' do
    it 'throws an error if one key is missing' do
      expect { ComlinkApiRequest.new('url', { 'access_key' => 'b' }) }.to raise_error(ArgumentError, 'Secret key missing')
      expect { ComlinkApiRequest.new('url', { 'secret_key' => 'b' }) }.to raise_error(ArgumentError, 'Access key missing')
    end
  end

  describe '#add_hmac_headers' do
    it 'should return the correct value' do
      comlink = ComlinkApiRequest.new('swgohcomlink.com', { access_key: 'ak', secret_key: 'sk' })

      dummy_request = Net::HTTP::Post.new('/')
      allow(Time).to receive(:now).and_return(Time.new(2024, 10, 1, 12, 0, 0))
      comlink.send(:add_hmac_headers, dummy_request, 'POST', '/testing', { arctic: 'monkeys' }.to_json)
      expect(dummy_request['Authorization']).to eq('HMAC-SHA256 Credential=ak,Signature=9c49c4d72438e751b105156f77be6d4742902a1516416dfa29b7a1513c66ab31')
    end
  end
end
