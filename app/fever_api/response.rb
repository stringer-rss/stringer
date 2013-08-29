require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"

require_relative "../commands/stories/mark_as_read"
require_relative "../commands/stories/mark_as_unread"

require_relative "../commands/stories/mark_as_starred"
require_relative "../commands/stories/mark_as_unstarred"
require_relative "../commands/stories/mark_feed_as_read"
require_relative "../commands/stories/mark_group_as_read"

module FeverAPI
  class Authentication
    def call(params)
      { auth: 1, last_refreshed_on_time: Time.now.to_i }
    end
  end

  class ReadGroups
    def call(params)
      if params.keys.include?('groups')
        { groups: groups }
      else
        {}
      end
    end

    private

    def groups
      [
        {
          id: 1,
          title: "All items"
        }
      ]
    end
  end

  class ReadFeeds
    def call(params)
      if params.keys.include?('feeds')
        { feeds: feeds }
      else
        {}
      end
    end

    private

    def feeds
      FeedRepository.list.map{|f| f.as_fever_json}
    end
  end

  class ReadFeedsGroups
    def call(params)
      if params.keys.include?('feeds') || params.keys.include?('groups')
        { feeds_groups: feeds_groups }
      else
        {}
      end
    end

    private

    def feeds_groups
      [
        {
          group_id: 1,
          feed_ids: Feed.all.map{|f| f.id}.join(",")
        }
      ]
    end
  end

  class ReadFavicons
    def call(params)
      if params.keys.include?('favicons')
        { favicons: favicons }
      else
        {}
      end
    end

    private

    def favicons
      [
        {
          id: 0,
          data: "image/gif;base64,R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
        }
      ]
    end
  end

  class ReadItems
    def call(params)
      if params.keys.include?('items')
        item_ids = params[:with_ids].split(',') rescue nil

        {
            items: items(item_ids, params[:since_id]),
            total_items: total_items(item_ids)
        }
      else
        {}
      end
    end

    private

    def items(item_ids, since_id)
      items = item_ids ? stories_by_ids(item_ids) : unread_stories(since_id)
      items.map{|s| s.as_fever_json }
    end

    def total_items(item_ids)
      items = item_ids ? stories_by_ids(item_ids) : unread_stories
      items.count
    end

    def stories_by_ids(ids)
      StoryRepository.fetch_by_ids(ids)
    end

    def unread_stories(since_id = nil)
      if since_id
        StoryRepository.unread_since_id(since_id)
      else
        StoryRepository.unread
      end
    end
  end

  class ReadLinks
    def call(params)
      if params.keys.include?('links')
        { links: links }
      else
        {}
      end
    end

    private

    def links
      []
    end
  end

  class SyncUnreadItemIds
    def call(params)
      if params.keys.include?('unread_item_ids')
        { unread_item_ids: unread_item_ids }
      else
        {}
      end
    end

    private

    def unread_item_ids
      unread_stories.map{|s| s.id}.join(',')
    end

    def unread_stories(since_id = nil)
      if since_id
        StoryRepository.unread_since_id(since_id)
      else
        StoryRepository.unread
      end
    end
  end

  class SyncSavedItemIds
    def call(params)
      if params.keys.include?('saved_item_ids')
        { saved_item_ids: saved_item_ids }
      else
        {}
      end
    end

    private

    def saved_item_ids
      all_starred_stories.map{|s| s.id}.join(',')
    end


    def all_starred_stories
      Story.where(is_starred: true)
    end
  end

  class WriteMarkItem
    def call(params)
      if params[:mark] == "item"
        case params[:as]
        when "read"
          MarkAsRead.new(params[:id]).mark_as_read
        when "unread"
          MarkAsUnread.new(params[:id]).mark_as_unread
        when "saved"
          MarkAsStarred.new(params[:id]).mark_as_starred
        when "unsaved"
          MarkAsUnstarred.new(params[:id]).mark_as_unstarred
        end
      end
    end
  end

  class WriteMarkFeed
    def call(params)
      if params[:mark] == "feed"
        MarkFeedAsRead.new(params[:id], params[:before]).mark_feed_as_read
      end
    end
  end

  class WriteMarkGroup
    def call(params)
      if params[:mark] == "group"
        MarkGroupAsRead.new(params[:id], params[:before]).mark_group_as_read
      end
    end
  end

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

      WriteMarkItem.new.call(params)
      WriteMarkFeed.new.call(params)
      WriteMarkGroup.new.call(params)
    end

    def to_json
      @response.to_json
    end
  end
end
