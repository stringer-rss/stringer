require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"
Bundler.require

require "./app"
require_relative "./app/tasks/fetch_feeds"
require_relative "./app/tasks/change_password"

desc "Fetch all feeds."
task :fetch_feeds do
  FetchFeeds.new(Feed.all).fetch_all
end

desc "Fetch single feed"
task :fetch_feed, :id do |t, args|
  FetchFeed.new(Feed.find(args[:id])).fetch
end

desc "Clear the delayed_job queue."
task :clear_jobs do
  Delayed::Job.delete_all
end

desc "Work the delayed_job queue."
task :work_jobs do
  Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
end

desc "Change your password"
task :change_password do
  ChangePassword.new.change_password
end

desc "Start server and serve JavaScript test suite at /test"
task :test_js do
  require_relative "./spec/javascript/test_controller"
  Stringer.run!
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:speedy_tests) do |t|
    t.rspec_opts = "--tag ~speed:slow"
  end

  RSpec::Core::RakeTask.new(:spec)

  task :default => [:speedy_tests]
rescue LoadError
  # allow for bundle install --without development:test
end
