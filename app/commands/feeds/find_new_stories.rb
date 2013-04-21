class FindNewStories
  def initialize(raw_feed, last_fetched, latest_url = nil)
    @raw_feed = raw_feed
    @last_fetched = last_fetched
    @latest_url = latest_url
  end

  def new_stories
    return [] if @raw_feed.last_modified &&
                 @raw_feed.last_modified < @last_fetched

    stories = []
    @raw_feed.stories.each do |story|
      break if @latest_url && story.url == @latest_url

      stories << story unless story.published && 
                              story.published < @last_fetched
    end

    stories
  end
end