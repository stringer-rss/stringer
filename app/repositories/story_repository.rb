require_relative "../helpers/url_helpers"
require_relative "../models/story"
require_relative "../utils/content_sanitizer"
require_relative "../utils/sample_story"

class StoryRepository
  extend UrlHelpers

  def self.add(entry, feed)
    Story.create(feed: feed,
                 title: extract_title(entry),
                 permalink: extract_url(entry, feed),
                 body: extract_content(entry),
                 is_read: false,
                 is_starred: false,
                 published: entry.published || Time.now,
                 entry_id: entry.id)
  end

  def self.fetch(id)
    Story.find(id)
  end

  def self.fetch_by_ids(ids)
    Story.where(id: ids)
  end

  def self.fetch_unread_by_timestamp(timestamp)
    timestamp = Time.at(timestamp.to_i)
    Story.where("stories.created_at < ?", timestamp).where(is_read: false)
  end

  def self.fetch_unread_by_timestamp_and_group(timestamp, group_id)
    fetch_unread_by_timestamp(timestamp).joins(:feed).where(feeds: { group_id: group_id })
  end

  def self.fetch_unread_for_feed_by_timestamp(feed_id, timestamp)
    timestamp = Time.at(timestamp.to_i)
    Story.where(feed_id: feed_id).where("created_at < ? AND is_read = ?", timestamp, false)
  end

  def self.save(story)
    story.save
  end

  def self.exists?(id, feed_id)
    Story.exists?(entry_id: id, feed_id: feed_id)
  end

  def self.unread
    Story.where(is_read: false).order("published desc").includes(:feed)
  end

  def self.unread_since_id(since_id)
    unread.where("id > ?", since_id)
  end

  def self.feed(feed_id)
    Story.where("feed_id = ?", feed_id).order("published desc").includes(:feed)
  end

  def self.read(page = 1)
    Story.where(is_read: true).includes(:feed)
         .order("published desc").page(page).per_page(20)
  end

  def self.starred(page = 1)
    Story.where(is_starred: true).includes(:feed)
         .order("published desc").page(page).per_page(20)
  end

  def self.all_starred
    Story.where(is_starred: true)
  end

  def self.unstarred_read_stories_older_than(num_days)
    Story.where(is_read: true, is_starred: false)
         .where("published <= ?", num_days.days.ago)
  end

  def self.read_count
    Story.where(is_read: true).count
  end

  def self.extract_url(entry, feed)
    return entry.enclosure_url if entry.url.nil? && entry.respond_to?(:enclosure_url)

    normalize_url(entry.url, feed.url) unless entry.url.nil?
  end

  def self.extract_content(entry)
    sanitized_content = ""

    if entry.content
      sanitized_content = ContentSanitizer.sanitize(entry.content)
    elsif entry.summary
      sanitized_content = ContentSanitizer.sanitize(entry.summary)
    end

    if entry.url.present?
      expand_absolute_urls(sanitized_content, entry.url)
    else
      sanitized_content
    end
  end

  def self.extract_title(entry)
    return ContentSanitizer.sanitize(entry.title) if entry.title.present?
    return ContentSanitizer.sanitize(entry.summary) if entry.summary.present?
    "There isn't a title for this story"
  end

  def self.samples
    [
      SampleStory.new("Darin' Fireballs", "Why you should trade your firstborn for a Retina iPad"),
      SampleStory.new("TechKrunch", "SugarGlidr raises $1.2M Series A for Social Network for Photo Filters"),
      SampleStory.new("Lambda Da Ultimate", "Flimsy types are the new hotness")
    ]
  end
end
