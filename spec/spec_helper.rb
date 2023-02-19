# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["RACK_ENV"] = "test"

require_relative "support/coverage"

require_relative "../config/environment"
require "rspec/rails"
require "capybara"
require "capybara/server"
require "rspec-html-matchers"
require "pry"
require "ostruct"
require "date"

require_relative "support/active_record"
require_relative "support/request_helpers"
require_relative "support/factory_bot"
require_relative "support/matchers"
require_relative "support/webmock"
require_relative "factories"

Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)
  config.include(RSpecHtmlMatchers)

  config.render_views
end
