# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

require_relative "support/coverage"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end
require "rspec/rails"

Rails.root.glob("spec/support/*.rb").each { |path| require path }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort(e.to_s.strip)
end

RSpec.configure do |config|
  config.include(RequestHelpers, type: :request)
  config.include(SystemHelpers, type: :system)
  config.include(ActiveSupport::Testing::TimeHelpers)

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
