require_relative "../../repositories/story_repository"

class FindNewStories
  STORY_AGE_THRESHOLD_DAYS = 3

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

      unless story_age_exceeds_threshold?(story) || StoryRepository.exists?(story.id, @feed_id)
        stories << story
      end
    end

    stories
  end

  private

  def story_age_exceeds_threshold?(story)
    max_age = Time.now - STORY_AGE_THRESHOLD_DAYS.days
    story.published && story.published < max_age
  end
end
