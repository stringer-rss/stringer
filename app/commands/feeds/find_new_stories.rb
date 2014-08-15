require_relative "../../repositories/story_repository"

class FindNewStories
  def initialize(raw_feed, feed_id, last_fetched, latest_entry_id = nil)
    @raw_feed = raw_feed
    @feed_id = feed_id
    @last_fetched = last_fetched
    @latest_entry_id = latest_entry_id
  end

  def new_stories
    stories = []

    @raw_feed.entries.each do |story|
      break if @latest_entry_id && story.id == @latest_entry_id

      stories << story unless StoryRepository.exists?(story.id, @feed_id)
    end

    stories
  end
end
