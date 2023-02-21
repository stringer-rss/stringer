# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["RACK_ENV"] = "test"

require_relative "support/coverage"

require_relative "../config/environment"
require "rspec/rails"
require "capybara/server"
require "rspec-html-matchers"
require "pry"
require "ostruct"
require "date"

require_relative "support/capybara"
require_relative "support/request_helpers"
require_relative "support/system_helpers"
require_relative "support/factory_bot"
require_relative "support/webmock"
require_relative "factories"

RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)
  config.include(SystemHelpers, type: :system)
  config.include(RSpecHtmlMatchers)
  config.include(ActiveSupport::Testing::TimeHelpers)

  config.use_transactional_fixtures = true

  config.render_views
end
