require_relative "../../models/feed"
require_relative "../../utils/opml_parser"
require "ostruct" # TODO: remove me, need a better way to create stories

class ImportFromGoogleReaderStars
  def self.import(starredjson_contents)
    json = JSON.parse(starredjson_contents, symbolize_names: true)
    items = json[:items]

    items.each do |item|
      feed_url = item[:origin][:streamId].sub('feed/', '')
      feed = FeedRepository.fetch_by_url(feed_url).first

      if feed.nil?
        # TODO: create a new feed? just skip for now
        next
      end

      stories = StoryRepository.fetch_by_feed_id(feed.id)
      story = stories.where(permalink: item[:alternate][0][:href]).first

      if story.nil?
        entry = {
          title: item[:title],
          url: item[:alternate][0][:href],
          content: item[:content].nil? ? nil : item[:content][:content],
          summary: item[:summary].nil? ? nil : item[:summary][:content],
          published: Time.at(item[:published])
        }
        entry_obj = OpenStruct.new entry
        story = StoryRepository.add(entry_obj, feed)
        story.is_read = true
      end

      story.is_starred = true
      StoryRepository.save(story)
    end
  end
end
