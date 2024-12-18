# frozen_string_literal: true

require_relative 'comlink_api_request'

# Base class for the gem, a wrapper for Comlink
# See https://github.com/swgoh-utils/swgoh-comlink for more info on Comlink
class SwgohComlink
  def initialize(comlink_url, **keys)
    @api_requester = ComlinkApiRequest.new(comlink_url, keys)
  end

  def enums
    JSON.parse(@api_requester.get('/enums'))
  end

  def localization(id, unzip = false, enums = false)
    body = { payload: { id: }, unzip:, enums: }

    parse_post_response('/localization', body)
  end

  def metadata(client_specs = {}, enums = false)
    body = {}
    unless client_specs.empty?
      body['payload'] = {
        clientSpecs: verify_parameters(client_specs, [:platform, :bundleId, :externalVersion, :internalVersion, :region])
      }
    end
    body['enums'] = enums

    parse_post_response('/metadata', body)
  end

  def data(version, include_pve_units = true, request_segment = 0, enums = false)
    body = {
      payload: {
        version:,
        includePveUnits: include_pve_units,
        requestSegment: request_segment
      },
      enums:
    }

    body_validation(body, [ { validation: (0..4), error_message: 'Request segment must be between 0 and 4', path: [:payload, :requestSegment] } ])

    parse_post_response('/data', body)
  end

  def player(player_id, enums = false)
    body = { payload: format_player_id_hash(player_id), enums: }

    parse_post_response('/player', body)
  end

  def player_arena(player_id, enums = false)
    body = {
      payload: format_player_id_hash(player_id),
      enums:
    }

    parse_post_response('/playerArena', body)
  end

  def guild(guild_id, include_recent_guild_activity = false, enums = false)
    body = {
      payload: {
        guildId: guild_id,
        includeRecentGuildActivityInfo: include_recent_guild_activity
      },
      enums:
    }

    parse_post_response('/guild', body)
  end

  def get_guilds(filter_type, name = nil, search_criteria = nil, count = 10, enums = false)
    body = {
      payload: {
        filterType: filter_type,
        count:,
        enums:
      }
    }

    validations = [ { validation: [4, 5], error_message: 'filterType must be 4 or 5', path: [:payload, :filterType], required: true } ]

    if filter_type == 4
      body[:payload][:name] = name
      validations << { error_message: 'Name is required when filterType is 4', path: [:payload, :name], required: true }
    elsif filter_type == 5
      body[:payload][:searchCriteria] = search_criteria && verify_parameters(search_criteria, [:minMemberCount, :maxMemberCount, :includeInviteOnly, :minGuildGalacticPower, :maxGuildGalacticPower, :recentTbParticipatedIn])
      validations << { error_message: 'searchCriteria is required when filterType is 5', path: [:payload, :searchCriteria], required: true }
    end

    body_validation(body, validations)

    parse_post_response('/getGuilds', body)
  end

  def get_events(enums = false)
    body = { enums: }

    parse_post_response('/getEvents', body)
  end

  def get_leaderboard(payload, enums = false)
    body_validation(payload, [ { validation: [4, 6], error_message: 'leaderboardType must be 4 or 6', path: [:leaderboardType] } ])

    if payload[:leaderboardType] == 4 || payload[:leaderboard_type] == 4
      payload = verify_parameters(payload, [:leaderboardType, :eventInstanceId, :groupId])
      body_validation(payload, [
        { error_message: 'eventInstanceId must be present', path: [:eventInstanceId], required: true },
        { error_message: 'groupId must be present', path: [:groupId], required: true }
      ])
    else
      payload = verify_parameters(payload, [:leaderboardType, :league, :division])
      body_validation(payload, [
        { validation: [20, 40, 60, 80, 100], error_message: 'league must be in [20, 40, 60, 80, 100]', path: [:league], required: true },
        { validation: [5, 10, 15, 20, 25], error_message: 'division must be in [5, 10, 15, 20, 25]', path: [:division], required: true }
      ])
    end

    body = { payload:, enums: }

    parse_post_response('/getLeaderboard', body)
  end

  def get_guild_leaderboard(leaderboards, count, enums = false)
    valid_def_ids = [
      'sith_raid',
      'rancor',
      'aat',
      'kraytdragon',
      'speederbike',
      't01D',
      't02D',
      't03D',
      't04D',
      't05D',
      'TERRITORY_WAR_LEADERBOARD',
      'GUILD:RAIDS:NORMAL_DIFF:RANCOR:DIFF06',
      'GUILD:RAIDS:NORMAL_DIFF:RANCOR:HEROIC80',
      'GUILD:RAIDS:NORMAL_DIFF:AAT:DIFF06',
      'GUILD:RAIDS:NORMAL_DIFF:AAT:HEROIC85',
      'GUILD:RAIDS:NORMAL_DIFF:SITH_RAID:DIFF06',
      'GUILD:RAIDS:NORMAL_DIFF:SITH_RAID:HEROIC85',
      'GUILD:RAIDS:NORMAL_DIFF:KRAYTDRAGON:DIFF01',
      'GUILD:RAIDS:NORMAL_DIFF:ROTJ:SPEEDERBIKE'
    ]

    leaderboards.each do |leaderboard|
      payload = verify_parameters(leaderboard, [:leaderboardType, :defId, :monthOffset])
      body_validation(leaderboard, [
        { validation: [0, 2, 3, 4, 5, 6], error_message: 'leaderboardType must in [0, 2, 3, 4, 5, 6]', path: [:leaderboardType], required: true },
        { validation: valid_def_ids, error_message: 'defId must be certain values, see docs', path: [:defId], required: [2, 4, 5, 6].include?(leaderboard.transform_keys(&:to_sym)[:leaderboardType]) },
        { validation: [0, 1], error_message: 'monthOffset must 0 or 1', path: [:monthOffset] }
      ])
    end

    body = {
      payload: {
        leaderboardId: leaderboards,
        count:
      },
      enums:
    }

    parse_post_response('/getGuildLeaderboard', body)
  end

  private

  def format_player_id_hash(player_id_original)
    # This can accept the 9 digit ally code (ex: 123-456-789)
    # OR it can accept the full playerId (ex: HFuvf-OURK202WASUgpayw)
    return { allyCode: player_id_original.to_s } if player_id_original.kind_of?(Integer)

    player_id = player_id_original.dup
    player_id.gsub!('-', '') if player_id.length == 11
    player_id.length == 9 ? { allyCode: player_id } : { playerID: player_id }
  end

  def verify_parameters(original_hash, permitted_keys)
    original_hash = original_hash.transform_keys(&:to_sym)

    original_hash.transform_keys! { |key| camelize(key.to_s).to_sym }
    original_hash.select { |key| permitted_keys.include?(key) }
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

  def parse_post_response(route, body)
    JSON.parse(@api_requester.post(route, body.to_json))
  end

  def camelize(string)
    string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub("/", "::")
  end
end
