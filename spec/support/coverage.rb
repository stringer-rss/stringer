# frozen_string_literal: true

return if ENV["COVERAGE"] == "false"

require "simplecov"

if ENV["CI"]
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start(:rails) do
  add_group("Commands", "app/commands")
  add_group("Fever API", "app/fever_api")
  add_group("Repositories", "app/repositories")
  add_group("Tasks", "app/tasks")
  add_group("Utils", "app/utils")
  enable_coverage :branch
end
SimpleCov.minimum_coverage(line: 100, branch: 100)
