require_relative "../../models/feed"
require_relative "../../utils/opml_parser"

class ImportFromGoogleReaderStars
  def self.import(starredjson_contents)
    skipped_feeds = []

    items_from_json_content(starredjson_contents).each do |item|
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
        story = create_story_from_item(item, feed)
        story.is_read = true
      end

      story.is_starred = true
      StoryRepository.save(story)
    end

    skipped_feeds
  end

  private

  def self.items_from_json_content(json_content)
    JSON.parse(json_content, symbolize_names: true)[:items]
  end

  def self.create_story_from_item(item, feed)
    Story.create(feed: feed,
                title: item[:title],
                permalink: item[:alternate][0][:href],
                body: StoryRepository.sanitize(!item[:content].nil? ? item[:content][:content] : (!item[:summary].nil? ? item[:summary][:content] : '')),
                is_read: false,
                is_starred: false,
                published: Time.at(item[:published]),
                entry_id: item[:id]) # since json doesn't provide guid just use the Google Reader id
  end
end
