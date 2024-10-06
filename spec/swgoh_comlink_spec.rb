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

    it 'requires requestSegment to be between 0 and 4' do
      expect { comlink.data("0.35.3:eD97HdfRTOG8C8c8qlajiQ", true, 23) }.to raise_error(ArgumentError, 'Request segment must be between 0 and 4')
    end
  end

  describe '#player' do
    it 'can retrieve player data' do
      expect(comlink.player('123456789')).to have_key('rosterUnit')
    end
  end

  describe '#player_arena' do
    it 'can retrieve player arena data' do
      expect(comlink.player_arena('123456789')).to have_key('pvpProfile')
    end
  end

  describe '#guild' do
    it 'can retrieve guild data' do
      expect(comlink.guild('bQq8wOSnQwSwk16NHgvwVQ')).to have_key('guild')
    end
  end

  describe '#get_guilds' do
    it 'can retrieve guild data with a search' do
      expect(comlink.get_guilds({filterType: 5}, {}, false)).to have_key('includeStarterGuild')
    end

    it 'requires filterType to be 4 or 5' do
      expect { comlink.get_guilds({}, {}, false) }.to raise_error(ArgumentError, 'filterType must be 4 or 5')
    end
  end

  describe '#get_events' do
    it 'can retrieve event data' do
      expect(comlink.get_events).to have_key('gameEvent')
    end
  end

  describe '#get_leaderboard' do
    it 'can retrieve GAC top 50 leaderboard data' do
      payload = {
        leaderboardType: 6,
        league: 100,
        division: 25
      }
      expect(comlink.get_leaderboard(payload)).to have_key('playerStatus')
    end


    it 'can retrieve GAC bracket leaderboard data' do
      payload = {
        leaderboardType: 4,
        eventInstanceId: "CHAMPIONSHIPS_GRAND_ARENA_GA2_EVENT_SEASON_36:O1676412000000",
        groupId: "CHAMPIONSHIPS_GRAND_ARENA_GA2_EVENT_SEASON_36:O1676412000000:KYBER:100"
      }
      expect(comlink.get_leaderboard(payload)).to have_key('playerStatus')
    end

    it 'errors when invalid leaderboardType' do
      payload = {
        leaderboardType: 505,
        eventInstanceId: "CHAMPIONSHIPS_GRAND_ARENA_GA2_EVENT_SEASON_36:O1676412000000",
        groupId: "CHAMPIONSHIPS_GRAND_ARENA_GA2_EVENT_SEASON_36:O1676412000000:KYBER:100"
      }
      expect { comlink.get_leaderboard(payload) }.to raise_error(ArgumentError, 'leaderboardType must be 4 or 6')
    end

    it 'errors when params do not match leaderboardType 6' do
      payload = {
        leaderboardType: 6,
        eventInstanceId: "CHAMPIONSHIPS_GRAND_ARENA_GA2_EVENT_SEASON_36:O1676412000000",
        groupId: "CHAMPIONSHIPS_GRAND_ARENA_GA2_EVENT_SEASON_36:O1676412000000:KYBER:100"
      }
      expect { comlink.get_leaderboard(payload) }.to raise_error(ArgumentError, 'league must be in [20, 40, 60, 80, 100]')
    end

    it 'errors when params do not match leaderboardType 4' do
      payload = {
        leaderboardType: 4,
        league: 100,
        division: 25
      }

      expect { comlink.get_leaderboard(payload) }.to raise_error(ArgumentError, 'eventInstanceId must be present')
    end
  end

  describe '#format_player_id_hash' do
    it 'can handle player id and ally code params' do
      expect(comlink.send(:format_player_id_hash, '123456789')).to eq({ allyCode: '123456789' })
      expect(comlink.send(:format_player_id_hash, '123-456-789')).to eq({ allyCode: '123456789' })
      expect(comlink.send(:format_player_id_hash, 'abcdef123456789')).to eq({ playerID: 'abcdef123456789' })
    end
  end

  describe '#verify_parameters' do
    permitted_keys = ['platform', 'bundleId', 'externalVersion', 'internalVersion', 'region']

    it 'can handle any unknown keys' do
      example_hash = {
        platform: 'Android',
        i_do_not_belong: 'hello'
      }

      expect(comlink.send(:verify_parameters, example_hash, permitted_keys)).to eq({ 'platform' => 'Android' })
    end

    it 'can handle symbols and strings as keys' do
      example_hash = {
        platform: 'Android',
        "bundleId" => 'com.sw'
      }

      expect(comlink.send(:verify_parameters, example_hash, permitted_keys)).to eq({ 'platform' => 'Android', 'bundleId' => 'com.sw' })
    end

    it 'can handle snake and camel case' do
      example_hash = {
        bundle_id:  'com.sw',
        externalVersion: '1.2.3'
      }

      expect(comlink.send(:verify_parameters, example_hash, permitted_keys)).to eq({ 'bundleId' => 'com.sw', 'externalVersion' => '1.2.3' })
    end

    it 'can handle an array of symbols too' do
      example_hash = {
        externalVersion: '1.2.3'
      }

      expect(comlink.send(:verify_parameters, example_hash, permitted_keys.map { |k| k.to_sym })).to eq({ 'externalVersion' => '1.2.3' })
    end
  end

  describe '#body_validation' do
    it 'errors when an invalid body' do
      body = { this_should_be_1: 0 }
      requirements = [ { validation: [ 1 ], error_message: 'This should be 1', path: [:this_should_be_1] } ]

      expect { comlink.send(:body_validation, body, requirements) }.to raise_error(ArgumentError, 'This should be 1')
    end

    it 'returns true if validation passes' do
      body = { this_should_be_1: 1 }
      requirements = [ { validation: [ 1 ], error_message: 'This should be 1', path: [:this_should_be_1] } ]

      expect(comlink.send(:body_validation, body, requirements)).to eq(true)
    end

    it 'errors when an invalid nested key' do
      body = { i_am_valid: { but_i_am_not: 0 } }
      requirements = [ { validation: [ 1 ], error_message: 'I should be 1', path: [:i_am_valid, :but_i_am_not] } ]

      expect { comlink.send(:body_validation, body, requirements) }.to raise_error(ArgumentError, 'I should be 1')
    end

    it 'returns true on a successful nested key check' do
      body = { i_am_valid: { and_i_am_too: 1 } }
      requirements = [ { validation: [ 1 ], error_message: 'I should be 1', path: [:i_am_valid, :and_i_am_too] } ]

      expect(comlink.send(:body_validation, body, requirements)).to eq(true)
    end

    it 'returns true when key does not exist and not required' do
      body = { i_am_valid: true }
      requirements = [ { validation: [ 20 ], error_message: 'I should be 20', path: [:i_am_also_valid] } ]

      expect(comlink.send(:body_validation, body, requirements)).to eq(true)
    end

    it 'returns true when just required with no validation' do
      body = { i_am_required: true }
      requirements = [ { error_message: 'I am required', path: [:i_am_required], required: true } ]

      expect(comlink.send(:body_validation, body, requirements)).to eq(true)
    end
  end
end
