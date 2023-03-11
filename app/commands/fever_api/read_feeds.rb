# frozen_string_literal: true

module FeverAPI::ReadFeeds
  class << self
    def call(authorization:, **params)
      if params.key?(:feeds)
        { feeds: feeds(authorization) }
      else
        {}
      end
    end

    private

    def feeds(authorization)
      authorization.scope(FeedRepository.list).map(&:as_fever_json)
    end
  end
end
