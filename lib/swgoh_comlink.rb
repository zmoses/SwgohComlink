# frozen_string_literal: true

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

  def player_data(player_id, enums = false)
    body = {
      payload: format_player_id_hash(player_id),
      enums: enums
    }

    JSON.parse(@api_requester.post('/player', body.to_json))
  end

  private

  def format_player_id_hash(player_id_string)
    player_id = player_id_string.dup
    player_id.gsub!('-', '') if player_id.length == 11
    player_id.length == 9 ? { allyCode: player_id } : { playerID: player_id }
  end
end
