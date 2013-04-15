require_relative "../models/story"

class StoryRepository
  def self.add(entry, feed)
    Story.create(feed: feed, 
                title: entry.title, 
                permalink: entry.url, 
                author: entry.author,
                body: entry.content.sanitize,
                is_read: false,
                published: entry.published)
  end

  def self.fetch(id)
    Story.find(id)
  end

  def self.save(story)
    story.save
  end

  def self.unread
    Story.where(is_read: false).order("published desc") 
  end

  def self.mark_all_as_read
    Story.update_all(is_read: false, is_read: true)
  end
end