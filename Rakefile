require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"
Bundler.require

require "./app"
require_relative "./app/tasks/fetch_feeds"

task :fetch_feeds do
  FetchFeeds.new(Feed.all).fetch_all
end

desc "Clear the delayed_job queue."
task :clear_jobs do
  Delayed::Job.delete_all
end

desc 'delayed_job worker process'
task :work_jobs do
  Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
end