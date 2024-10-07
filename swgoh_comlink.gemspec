Gem::Specification.new do |s|
  s.name        = 'swgoh_comlink'
  s.version     = '0.0.1'
  s.summary     = 'Created to connect with deployed Star Wars: Galaxy of Heroes Comlink APIs. For more information on Comlink, see their Github page: https://github.com/swgoh-utils/swgoh-comlink'
  s.description = 'A wrapper to connect to SWGOH Comlink APIs'
  s.authors     = ['Zach Moses']
  s.email       = 'zmoses93@gmail.com'
  s.files       = ['lib/swgoh_comlink.rb', 'lib/comlink_api_request.rb']
  s.homepage    = 'https://github.com/zmoses/SwgohComlink'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'webmock'
end
