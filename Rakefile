# frozen_string_literal: true

require_relative "config/application"

Rails.application.load_tasks

desc "Fetch all feeds."
task fetch_feeds: :environment do
  Feed::FetchAll.call
end

desc "Lazily fetch all feeds."
task lazy_fetch: :environment do
  if ENV["APP_URL"]
    uri = URI(ENV["APP_URL"])

    # warm up server by fetching the root path
    Net::HTTP.get_response(uri)
  end

  FeedRepository.list.each do |feed|
    CallableJob.perform_later(Feed::FetchOne, feed)
  end
end

desc "Fetch single feed"
task :fetch_feed, [:id] => :environment do |_t, args|
  Feed::FetchOne.call(Feed.find(args[:id]))
end

desc "Clean up old stories that are read and unstarred"
task :cleanup_old_stories, [:number_of_days] => :environment do |_t, args|
  args.with_defaults(number_of_days: 30)
  RemoveOldStories.call(args[:number_of_days].to_i)
end
