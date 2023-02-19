# frozen_string_literal: true

module FeverAPI
  API_VERSION = 3

  module Response
    ACTIONS = [
      Authentication,

      ReadFeeds,
      ReadGroups,
      ReadFeedsGroups,
      ReadFavicons,
      ReadItems,
      ReadLinks,

      SyncUnreadItemIds,
      SyncSavedItemIds,

      WriteMarkItem,
      WriteMarkFeed,
      WriteMarkGroup
    ].freeze

    def self.call(params)
      base_response = { api_version: API_VERSION }
      ACTIONS.reduce(base_response) { |a, e| a.merge!(e.call(params)) }.to_json
    end
  end
end
