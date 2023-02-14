# frozen_string_literal: true

module FeverAPI
  API_VERSION = 3

  class Response
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

    def initialize(params)
      @params = params
    end

    def to_json(*_args)
      base_response = { api_version: API_VERSION }
      ACTIONS.reduce(base_response) { |a, e| a.merge!(e.call(@params)) }.to_json
    end
  end
end
