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

  describe '#player_data' do
    it 'can retrieve player data' do
      expect(comlink.player_data('123456789')).to have_key('rosterUnit')
    end
  end

  describe '#format_player_id_hash' do
    it 'can handle player id and ally code params' do
      expect(comlink.send(:format_player_id_hash, '123456789')).to eq({ allyCode: '123456789' })
      expect(comlink.send(:format_player_id_hash, '123-456-789')).to eq({ allyCode: '123456789' })
      expect(comlink.send(:format_player_id_hash, 'abcdef123456789')).to eq({ playerID: 'abcdef123456789' })
    end
  end
end
