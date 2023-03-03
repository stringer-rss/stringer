# frozen_string_literal: true

module FeverAPI
  API_VERSION = 3

  PARAMS = [
    :as,
    :before,
    :favicons,
    :feeds,
    :groups,
    :id,
    :items,
    :links,
    :mark,
    :saved_item_ids,
    :since_id,
    :unread_item_ids,
    :with_ids
  ].freeze

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
      result = { api_version: API_VERSION }
      ACTIONS.each { |action| result.merge!(action.call(**params)) }
      result.to_json
    end
  end
end
