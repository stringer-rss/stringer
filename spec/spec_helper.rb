ENV["RACK_ENV"] = "test"

require "rspec"
require "rspec-html-matchers"
require "rack/test"
require "pry"
require "faker"
require "ostruct"
require "date"

require_relative "support/coverage"
require "factories/feed_factory"
require "factories/story_factory"
require "factories/user_factory"
require "factories/group_factory"
require "factories/users"

require "./app"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers
  config.include Factories
end

def app_require(file)
  require File.expand_path(File.join("app", file))
end

def app
  Stringer
end

def session
  last_request.env["rack.session"]
end
