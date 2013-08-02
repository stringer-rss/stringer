class FindNewStories
  def initialize(raw_feed, last_fetched, latest_story = nil)
    @raw_feed = raw_feed
    @last_fetched = last_fetched
    @latest_story = latest_story
  end

  def new_stories
    return [] if @raw_feed.last_modified &&
                 @raw_feed.last_modified < @last_fetched

    stories = []
    @raw_feed.entries.each do |story|
      break if seen_story_before?(story)

      stories << story unless story.published &&
                              story.published < @last_fetched
    end

    stories
  end

  def seen_story_before?(story)
    return false unless @latest_story

    if @latest_story.entry_id
      story.entry_id == @latest_story.entry_id
    elsif @latest_story.permalink
      story.url == @latest_story.permalink
    end
  end
end
