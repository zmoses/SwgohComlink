# frozen_string_literal: true

require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require_relative 'comlink_api_request'

require 'pry'

# Base class for the gem, a wrapper for Comlink
# See https://github.com/swgoh-utils/swgoh-comlink for more info on Comlink
class SwgohComlink
  def initialize(comlink_url, keys = {})
    @api_requester = ComlinkApiRequest.new(comlink_url, keys)
  end

  def enums
    JSON.parse(@api_requester.get('/enums'))
  end

  def localization(id, unzip = false, enums = false)
    body = {
      payload: {
        id: id
      },
      unzip: unzip,
      enums: enums
    }

    JSON.parse(@api_requester.post('/localization', body.to_json))
  end

  def metadata(client_specs = {}, enums = false)
    body = {}
    body['payload'] = { "clientSpecs" => verify_parameters(client_specs, ['platform', 'bundleId', 'externalVersion', 'internalVersion', 'region']) } unless client_specs.empty?
    body['enums'] = false

    JSON.parse(@api_requester.post('/metadata', body.to_json))
  end

  def data(version, include_pve_units = true, request_segment = 0, enums = false)
    body = {
      payload: {
        version: version,
        includePveUnits: include_pve_units,
        requestSegment: request_segment
      },
      enums: enums
    }

    body_validation(body, [ { validation: (0..4), error_message: 'Request segment must be between 0 and 4', path: [:payload, :requestSegment] } ])

    JSON.parse(@api_requester.post('/data', body.to_json))
  end

  def player(player_id, enums = false)
    body = {
      payload: format_player_id_hash(player_id),
      enums: enums
    }

    JSON.parse(@api_requester.post('/player', body.to_json))
  end

  def player_arena(player_id, enums = false)
    body = {
      payload: format_player_id_hash(player_id),
      enums: enums
    }

    JSON.parse(@api_requester.post('/playerArena', body.to_json))
  end

  def guild(guild_id, include_recent_guild_activity = false, enums = false)
    body = {
      payload: {
        guildId: guild_id,
        includeRecentGuildActivityInfo: include_recent_guild_activity
      },
      enums: enums
    }

    JSON.parse(@api_requester.post('/guild', body.to_json))
  end

  def get_guilds(payload, search_criteria, enums = false)
    body = {}
    body[:payload] = verify_parameters(payload, ['filterType', 'startIndex', 'count', 'name'])
    body[:payload][:searchCriteria] = verify_parameters(search_criteria, ['minMemberCount', 'maxMemberCount', 'includeInviteOnly', 'minGuildGalacticPower', 'maxGuildGalacticPower', 'recentTbParticipatedIn'])
    body[:enums] = enums

    body_validation(body, [ { validation: [4, 5], error_message: 'filterType must be 4 or 5', path: [:payload, :filterType], required: true } ])

    JSON.parse(@api_requester.post('/getGuilds', body.to_json))
  end

  def get_events(enums = false)
    body = {
      enums: enums
    }

    JSON.parse(@api_requester.post('/getEvents', body.to_json))
  end

  def get_leaderboard(payload, enums = false)
    body_validation(payload, [ { validation: [4, 6], error_message: 'leaderboardType must be 4 or 6', path: [:leaderboardType] } ])

    if payload[:leaderboardType] == 4 || payload[:leaderboard_type] == 4
      payload = verify_parameters(payload, ['leaderboardType', 'eventInstanceId', 'groupId'])
      body_validation(payload, [
        { error_message: 'eventInstanceId must be present', path: [:eventInstanceId], required: true },
        { error_message: 'groupId must be present', path: [:groupId], required: true }
      ])
    else
      payload = verify_parameters(payload, ['leaderboardType', 'league', 'division'])
      body_validation(payload, [
        { validation: [20, 40, 60, 80, 100], error_message: 'league must be in [20, 40, 60, 80, 100]', path: [:league], required: true },
        { validation: [5, 10, 15, 20, 25], error_message: 'division must be in [5, 10, 15, 20, 25]', path: [:division], required: true }
      ])
    end

    body = {
      payload: payload,
      enums: false
    }

    JSON.parse(@api_requester.post('/getLeaderboard', body.to_json))
  end

  private

  def format_player_id_hash(player_id_original)
    # This can accept the 9 digit ally code (ex: 123-456-789)
    # OR it can accept the full playerId (ex: HFuvf-OURK202WASUgpayw)
    player_id = player_id_original.dup
    player_id.gsub!('-', '') if player_id.length == 11
    player_id.length == 9 ? { allyCode: player_id } : { playerID: player_id }
  end

  def verify_parameters(original_hash, permitted_keys)
    original_hash = original_hash.with_indifferent_access

    original_hash.transform_keys! { |key| key.to_s.camelize(:lower) }
    original_hash.slice!(*permitted_keys)

    original_hash
  end

  def body_validation(body, requirements)
    requirements.each do |req_set|
      value = body.dig(*req_set[:path])
      next if !value && !req_set[:required]
      next if value && (!req_set[:validation] || req_set[:validation].include?(value))

      raise ArgumentError, req_set[:error_message]
    end

    true
  end
end
