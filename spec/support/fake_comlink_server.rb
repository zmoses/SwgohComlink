require 'sinatra/base'

class FakeComlinkServer < Sinatra::Base
  get '/:route' do
    json_response 200, "#{params['route']}.json"
  end

  post '/:route' do
    json_response 200, "#{params['route']}.json"
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end