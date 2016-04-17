require "clockwork"
require "delayed_job"
require "delayed_job_active_record"

require_relative "../app"
require_relative "../app/jobs/fetch_feed_job"
require_relative "../app/repositories/feed_repository"

include Clockwork

fetch_interval = (ENV["FETCH_INTERVAL"] || 60).to_i
every(fetch_interval.seconds, "clockwork.frequent") do
  FeedRepository.list.each do |feed|
    Delayed::Job.enqueue FetchFeedJob.new(feed.id)
  end
end
