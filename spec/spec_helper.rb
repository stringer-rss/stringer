ENV['RACK_ENV'] = 'test'

require "rspec"
require "rack/test"
require "pry"
require "ostruct"
require "date"

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app_require(file)
  require File.expand_path(File.join("app", file))
end