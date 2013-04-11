class StoryRepository
  def self.add(entry, feed)
    Story.create(feed: feed, title: entry.title, permalink: entry.url, body: entry.content.sanitize)
  end
end