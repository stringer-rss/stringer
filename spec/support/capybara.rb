# frozen_string_literal: true

require "capybara/rails"

Capybara.enable_aria_label = true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:selenium, using: :firefox)
  end
end
