ENV["RACK_ENV"] = "test"
ENV["ENFORCE_SSL"] = "true"

require "capybara"
require "capybara/server"
require "rspec"
require "rspec-html-matchers"
require "rack/test"
require "pry"
require "faker"
require "ostruct"
require "date"

require_relative "support/coverage"
require_relative "support/factory_bot"
require_relative "factories"

require "./app"

Capybara.server = :puma, { Silent: true }

module Rack
  module Test
    class Session
      alias old_custom_request custom_request

      def custom_request(method, path, params = {}, env = {}, &)
        env["HTTPS"] = "on"
        old_custom_request(method, path, params, env, &)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers
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
