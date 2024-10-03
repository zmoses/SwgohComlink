require 'sinatra/base'

class FakeComlinkServer < Sinatra::Base
  get '/enums' do
    json_response 200, 'enums.json'
  end

  post '/player' do
    json_response 200, 'player.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end