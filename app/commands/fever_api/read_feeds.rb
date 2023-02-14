# frozen_string_literal: true

module FeverAPI
  class ReadFeeds
    def self.call(params)
      new.call(params)
    end

    def initialize(options = {})
      @feed_repository = options.fetch(:feed_repository) { FeedRepository }
    end

    def call(params = {})
      if params.keys.include?("feeds")
        { feeds: }
      else
        {}
      end
    end

    private

    def feeds
      @feed_repository.list.map(&:as_fever_json)
    end
  end
end
