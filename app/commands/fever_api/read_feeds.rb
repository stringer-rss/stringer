# frozen_string_literal: true

module FeverAPI
  module ReadFeeds
    class << self
      def call(params)
        if params.key?(:feeds)
          { feeds: }
        else
          {}
        end
      end

      private

      def feeds
        FeedRepository.list.map(&:as_fever_json)
      end
    end
  end
end
