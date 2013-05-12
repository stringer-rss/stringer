ENV['RACK_ENV'] = 'test'

require "rspec"
require "rspec-html-matchers"
require "rack/test"
require "pry"
require "faker"
require "ostruct"
require "date"

require "coveralls"
Coveralls.wear!

require "factories/feed_factory"
require "factories/story_factory"
require "factories/user_factory"

require "./app"

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app_require(file)
  require File.expand_path(File.join("app", file))
end

def app
  Stringer
end

def session
  last_request.env['rack.session']
end
