# frozen_string_literal: true

require "bundler"
Bundler.setup

require "rubygems"
require "net/http"
require "active_record"
require "active_support/core_ext/kernel/reporting"
require "delayed_job"
require "delayed_job_active_record"

require "sinatra/activerecord/rake"
ActiveRecord::Tasks::DatabaseTasks.db_dir = "db"

require "./app"

desc "Load app files"
task :environment do
  require_relative "./app/jobs/fetch_feed_job"
  require_relative "./app/tasks/fetch_feeds"
  require_relative "./app/tasks/change_password"
  require_relative "./app/tasks/remove_old_stories"
end

desc "Open an irb session preloaded with the app"
task :console do
  sh "irb -r ./app.rb"
end

desc "Fetch all feeds."
task fetch_feeds: :environment do
  FetchFeeds.new(Feed.all).fetch_all
end

desc "Lazily fetch all feeds."
task lazy_fetch: :environment do
  if ENV["APP_URL"]
    uri = URI(ENV["APP_URL"])
    Net::HTTP.get_response(uri)
  end

  FeedRepository.list.each do |feed|
    Delayed::Job.enqueue(FetchFeedJob.new(feed.id))
  end
end

desc "Fetch single feed"
task :fetch_feed, [:id] => :environment do |_t, args|
  FetchFeed.new(Feed.find(args[:id])).fetch
end

desc "Clear the delayed_job queue."
task clear_jobs: :environment do
  Delayed::Job.delete_all
end

desc "Work the delayed_job queue."
task work_jobs: :environment do
  Delayed::Job.delete_all

  worker_retry = Integer(ENV["WORKER_RETRY"] || 3)
  worker_retry.times do
    Delayed::Worker.new(
      min_priority: ENV["MIN_PRIORITY"],
      max_priority: ENV["MAX_PRIORITY"]
    ).start
  end
end

desc "Change your password"
task change_password: :environment do
  ChangePassword.new.change_password
end

desc "Clean up old stories that are read and unstarred"
task :cleanup_old_stories, [:number_of_days] => :environment do |_t, args|
  args.with_defaults(number_of_days: 30)
  RemoveOldStories.remove!(args[:number_of_days].to_i)
end
