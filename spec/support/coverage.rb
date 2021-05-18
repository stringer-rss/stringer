require "simplecov"

if ENV["CI"]
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start("test_frameworks") do
  add_group("Commands", "app/commands")
  add_group("Controllers", "app/controllers")
  add_group("Fever API", "app/fever_api")
  add_group("Helpers", "app/helpers")
  add_group("Models", "app/models")
  add_group("Repositories", "app/repositories")
  add_group("Tasks", "app/tasks")
  add_group("Utils", "app/utils")
  add_filter("/db/migrate/")
end
SimpleCov.minimum_coverage(100)
