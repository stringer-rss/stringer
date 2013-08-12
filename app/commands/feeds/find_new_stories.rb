class FindNewStories
  def initialize(raw_feed, last_fetched, latest_entry_id = nil)
    @raw_feed = raw_feed
    @last_fetched = last_fetched
    @latest_entry_id = latest_entry_id
  end

  def new_stories
    return [] if @raw_feed.last_modified &&
                 @raw_feed.last_modified < @last_fetched

    stories = []
    @raw_feed.entries.each do |story|
      break if @latest_entry_id && story.id == @latest_entry_id

      stories << story unless story.published &&
                              story.published < @last_fetched
    end

    stories
  end
end
