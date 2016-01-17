require_relative "authentication"

require_relative "read_groups"
require_relative "read_feeds"
require_relative "read_feeds_groups"
require_relative "read_favicons"
require_relative "read_items"
require_relative "read_links"

require_relative "sync_unread_item_ids"
require_relative "sync_saved_item_ids"

require_relative "write_mark_item"
require_relative "write_mark_feed"
require_relative "write_mark_group"

module FeverAPI
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
    ]

    def initialize(params)
      @params = params
    end

    def to_json
      base_response = { api_version: 3 }
      ACTIONS
        .inject(base_response) { |a, e| a.merge!(e.new.call(@params)) }
        .to_json
    end
  end
end
