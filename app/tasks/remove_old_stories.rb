class RemoveOldStories
  def self.remove!(number_of_days)
    stories = old_stories(number_of_days)
    feeds = pruned_feeds(stories)

    stories.delete_all
    feeds.each { |feed| FeedRepository.update_last_fetched(feed, Time.now) }
  end

  def self.old_stories(number_of_days)
    StoryRepository.unstarred_read_stories_older_than(number_of_days)
  end

  def self.pruned_feeds(stories)
    FeedRepository.fetch_by_ids(stories.map(&:feed_id))
  end
end
