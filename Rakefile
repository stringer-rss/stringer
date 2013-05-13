require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"
Bundler.require

require "./app"
require_relative "./app/tasks/fetch_feeds"

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

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:speedy_tests) do |t|
  t.rspec_opts = "--tag ~speed:slow"
end

RSpec::Core::RakeTask.new(:spec)

task :default => [:speedy_tests]
