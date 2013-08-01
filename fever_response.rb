require_relative "app/repositories/story_repository"
require_relative "app/repositories/feed_repository"

require_relative "app/commands/stories/mark_as_read"
require_relative "app/commands/stories/mark_as_unread"

require_relative "app/commands/stories/mark_as_starred"
require_relative "app/commands/stories/mark_as_unstarred"
require_relative "app/commands/stories/mark_feed_as_read"
require_relative "app/commands/stories/mark_group_as_read"

module Fever
  class Response
    def initialize(params)
      response = {}

      response[:api_version] = 3
      response[:auth] = 1
      response[:last_refreshed_on_time] = Time.now.to_i

      keys = params.keys.map{|k| k.to_sym}

      if keys.include?(:groups)
        response[:groups] = groups
        response[:feeds_groups] = feeds_groups
      end

      if keys.include?(:feeds)
        response[:feeds] = feeds.map{|f| f.as_fever_json}
        response[:feeds_groups] = feeds_groups
      end

      if keys.include?(:favicons)
        response[:favicons] = favicons
      end

      if keys.include?(:items)
        item_ids = params[:with_ids].split(',') rescue nil
        response[:items] = items(item_ids, params[:since_id])
        response[:total_items] = total_items(item_ids)
      end

      if keys.include?(:links)
        response[:links] = links
      end

      if keys.include?(:unread_item_ids)
        response[:unread_item_ids] = unread_item_ids
      end

      if keys.include?(:saved_item_ids)
        response[:saved_item_ids] = saved_item_ids
      end

      case params[:mark]
      when "item"
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
      when "feed"
        MarkFeedAsRead.new(params[:id], params[:before]).mark_feed_as_read
      when "group"
        MarkGroupAsRead.new(params[:id], params[:before]).mark_group_as_read
      end

      @response = response
    end

    def to_json
      @response.to_json
    end

  protected

    def groups
      [
        {
          id: 1,
          title: "All items"
        }
      ]
    end

    def feeds_groups
      [
        {
          group_id: 1,
          feed_ids: Feed.all.map{|f| f.id}.join(",")
        }
      ]
    end

    def feeds
      FeedRepository.list
    end

    def favicons
      [
        {
          id: 0,
          data: "image/gif;base64,R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
        }
      ]
    end

    def items(item_ids, since_id)
      items = item_ids ? stories_by_ids(item_ids) : unread_stories(since_id)
      items.map{|s| s.as_fever_json}
    end

    def total_items(item_ids)
      items = item_ids ? stories_by_ids(item_ids) : unread_stories
      items.count
    end

    def links
      []
    end

    def unread_item_ids
      unread_stories.map{|s| s.id}.join(',')
    end

    def saved_item_ids
      all_starred_stories.map{|s| s.id}.join(',')
    end

    def unread_stories(since_id = nil)
      if since_id
        StoryRepository.unread_since_id(since_id)
      else
        StoryRepository.unread
      end
    end

    def all_starred_stories
      Story.where(is_starred: true)
    end

    def stories_by_ids(ids)
      StoryRepository.fetch_by_ids(ids)
    end
  end
end

