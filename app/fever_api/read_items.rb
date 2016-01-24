require_relative "../repositories/story_repository"

module FeverAPI
  class ReadItems
    def initialize(options = {})
      @story_repository = options.fetch(:story_repository) { StoryRepository }
    end

    def call(params = {})
      if params.keys.include?("items")
        item_ids = begin
                     params[:with_ids].split(",")
                   rescue
                     nil
                   end

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
      items.map(&:as_fever_json)
    end

    def total_items(item_ids)
      items = item_ids ? stories_by_ids(item_ids) : unread_stories
      items.count
    end

    def stories_by_ids(ids)
      @story_repository.fetch_by_ids(ids)
    end

    def unread_stories(since_id = nil)
      if since_id
        @story_repository.unread_since_id(since_id)
      else
        @story_repository.unread
      end
    end
  end
end
