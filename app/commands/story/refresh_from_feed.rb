# frozen_string_literal: true

module RefreshFromFeed
  class << self
    def call(story)
      entry = find_entry(story)
      return false if entry.nil?

      StoryRepository.update_from_entry(story, entry)

      true
    rescue StandardError => e
      Rails.logger.error(
        "Something went wrong when refreshing story #{story.id}: #{e}"
      )

      false
    end

    private

    def find_entry(story)
      response = SafeFetch.body(story.feed.url)
      raw_feed = Feedjira.parse(response)

      raw_feed.entries.find { |entry| entry.id == story.entry_id }
    end
  end
end
