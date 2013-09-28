require_relative "../../models/feed"
require_relative "../../utils/opml_parser"
require "ostruct"

class ImportFromGoogleReaderStars
  def self.import(starredjson_contents)
    json = JSON.parse(starredjson_contents, symbolize_names: true)
    items = json[:items]

    skipped_feeds = []

    items.each do |item|
      feed_url = item[:origin][:streamId].sub('feed/', '')
      feed = FeedRepository.fetch_by_url(feed_url).first

      # Skip this item if its feed is not subscribed to
      if feed.nil?
        skipped_feeds.push feed_url unless skipped_feeds.include? feed_url
        next
      end

      # Check for whether this story already exists by permalink
      # NOT by entry_id as the json doesn't contain the guid supplied by the feed
      stories = StoryRepository.fetch_by_feed_id(feed.id)
      story = stories.where(permalink: item[:alternate][0][:href]).first

      if story.nil?
        story = StoryRepository.add(create_story_from_item(item), feed)
        story.is_read = true
      end

      story.is_starred = true
      StoryRepository.save(story)
    end

    skipped_feeds
  end

  private

  def self.create_story_from_item(item)
    entry = {
      title: item[:title],
      url: item[:alternate][0][:href],
      content: item[:content].nil? ? nil : item[:content][:content],
      summary: item[:summary].nil? ? nil : item[:summary][:content],
      published: Time.at(item[:published]),
      id: item[:id] # since json doesn't provide guid just use the Google Reader id
    }
    OpenStruct.new entry
  end
end
