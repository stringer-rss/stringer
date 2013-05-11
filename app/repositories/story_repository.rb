require_relative "../models/story"
require_relative "../utils/sample_story"

class StoryRepository
  def self.add(entry, feed)
    Story.create(feed: feed, 
                title: entry.title, 
                permalink: entry.url, 
                body: StoryRepository.extract_content(entry),
                is_read: false,
                published: entry.published || Time.now)
  end

  def self.fetch(id)
    Story.find(id)
  end

  def self.fetch_by_ids(ids)
    Story.where(id: ids)
  end

  def self.save(story)
    story.save
  end

  def self.unread
    Story.where(is_read: false).order("published desc") 
  end

  def self.read(page = 1)
    Story.where(is_read: true).order("published desc").page(page).per_page(15)
  end

  def self.read_count
    Story.where(is_read: true).count
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

  def self.samples
    [
      SampleStory.new("Darin' Fireballs", "Why you should trade your firstborn for a Retina iPad"),
      SampleStory.new("TechKrunch", "SugarGlidr raises $1.2M Series A for Social Network for Photo Filters"),
      SampleStory.new("Lambda Da Ultimate", "Flimsy types are the new hotness")
    ]
  end
end