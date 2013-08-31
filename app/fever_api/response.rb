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
    def initialize(params)
      @response = { api_version: 3 }

      @response.merge! Authentication.new.call(params)

      @response.merge! ReadFeeds.new.call(params)
      @response.merge! ReadGroups.new.call(params)
      @response.merge! ReadFeedsGroups.new.call(params)
      @response.merge! ReadFavicons.new.call(params)
      @response.merge! ReadItems.new.call(params)
      @response.merge! ReadLinks.new.call(params)

      @response.merge! SyncUnreadItemIds.new.call(params)
      @response.merge! SyncSavedItemIds.new.call(params)

      @response.merge! WriteMarkItem.new.call(params)
      @response.merge! WriteMarkFeed.new.call(params)
      @response.merge! WriteMarkGroup.new.call(params)
    end

    def to_json
      @response.to_json
    end
  end
end
