require "sinatra/base"
require "sinatra/activerecord"
require "digest/md5"

require_relative "app/repositories/story_repository"
require_relative "app/repositories/feed_repository"

require_relative "app/commands/stories/mark_as_read"
require_relative "app/commands/stories/mark_as_unread"

require_relative "app/commands/stories/mark_as_starred"
require_relative "app/commands/stories/mark_as_unstarred"
require_relative "app/commands/stories/mark_group_as_read"

class FeverAPI < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"

    register Sinatra::ActiveRecordExtension
    ActiveRecord::Base.include_root_in_json = false
  end

  before do
    halt 403 unless authenticated?(params[:api_key])
  end

  def authenticated?(api_key)
    user = User.first
    user.api_key && api_key.downcase == user.api_key.downcase
  end

  get "/" do
    content_type :json
    get_response(params)
  end

  post "/" do
    content_type :json
    get_response(params)
  end

  def get_response(params, is_json = true)
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
      response[:favicons] = [
        {
          id: 0,
          data: "image/gif;base64,R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
        }
      ]
    end

    if keys.include?(:items)
      if keys.include?(:with_ids)
        response[:items] = stories_by_ids(params[:with_ids].split(",")).map{|s| s.as_fever_json}
        response[:total_items] = stories_by_ids(params[:with_ids].split(",")).count
      else
        response[:items] = unread_stories(params[:since_id]).map{|s| s.as_fever_json}
        response[:total_items] = unread_stories.count
      end
    end

    if keys.include?(:links)
      response[:links] = []
    end

    if keys.include?(:unread_item_ids)
      response[:unread_item_ids] = unread_stories.map{|s| s.id}.join(",")
    end

    if keys.include?(:saved_item_ids)
      response[:saved_item_ids] = all_starred_stories.map{|s| s.id}.join(",")
    end

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
    elsif params[:mark] == "group"
      MarkGroupAsRead.new(params[:id], params[:before]).mark_group_as_read
    end

    response.to_json
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

  def feeds
    FeedRepository.list
  end

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
end

