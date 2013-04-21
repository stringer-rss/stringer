require_relative "../models/story"

class StoryRepository
  def self.add(entry, feed)
    Story.create(feed: feed, 
                title: entry.title, 
                permalink: entry.url, 
                author: entry.author,
                body: StoryRepository.extract_content(entry),
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

  def self.extract_content(entry)
    if entry.content
      entry.content.sanitize
    elsif entry.summary
      entry.summary.sanitize
    else
      ""
    end
  end
end