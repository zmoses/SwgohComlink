# frozen_string_literal: true

require 'spec_helper'

describe SwgohComlink do
  # swgohcomlink.com stubs out to the fake server, do not change
  comlink = SwgohComlink.new('swgohcomlink.com', { access_key: 'ak', secret_key: 'sk' })

  describe '#enums' do
    it 'can retrieve enums' do
      expect(comlink.enums).to have_key('AbilityButtonLocationType')
    end
  end

  describe '#metadata' do
    it 'can retrieve metadata' do
      expect(comlink.metadata({platform: 'Android'}, true)).to have_key('config')
    end
  end

  describe '#localization' do
    it 'can retrieve localization info' do
      expect(comlink.localization("aEoiQSV5QHOy0fysbrX8RA:ENG_US", true)).to have_key('Loc_ENG_US.txt')
    end
  end

  describe '#data' do
    it 'can retrieve data info' do
      expect(comlink.data("0.35.3:eD97HdfRTOG8C8c8qlajiQ", true)).to have_key('battleEnvironments')
    end
  end

  describe '#player' do
    it 'can retrieve player data' do
      expect(comlink.player('123456789')).to have_key('rosterUnit')
    end
  end

  describe '#format_player_id_hash' do
    it 'can handle player id and ally code params' do
      expect(comlink.send(:format_player_id_hash, '123456789')).to eq({ allyCode: '123456789' })
      expect(comlink.send(:format_player_id_hash, '123-456-789')).to eq({ allyCode: '123456789' })
      expect(comlink.send(:format_player_id_hash, 'abcdef123456789')).to eq({ playerID: 'abcdef123456789' })
    end
  end

  describe '#verify_client_specs' do
    it 'can handle any unknown client_specs keys' do
      example_client_specs = {
        platform: 'Android',
        i_do_not_belong: 'hello'
      }

      expect(comlink.send(:verify_client_specs, example_client_specs)).to eq({ 'platform' => 'Android' })
    end

    it 'can handle symbols and strings as keys' do
      example_client_specs = {
        platform: 'Android',
        "bundleId" => 'com.sw'
      }

      expect(comlink.send(:verify_client_specs, example_client_specs)).to eq({ 'platform' => 'Android', 'bundleId' => 'com.sw' })
    end

    it 'can handle snake and camel case' do
      example_client_specs = {
        bundle_id:  'com.sw',
        externalVersion: '1.2.3'
      }

      expect(comlink.send(:verify_client_specs, example_client_specs)).to eq({ 'bundleId' => 'com.sw', 'externalVersion' => '1.2.3' })
    end
  end
end
