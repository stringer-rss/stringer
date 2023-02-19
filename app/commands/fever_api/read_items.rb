# frozen_string_literal: true

module FeverAPI
  module ReadItems
    class << self
      def call(params)
        if params.keys.include?("items")
          item_ids =
            begin
              params[:with_ids].split(",")
            rescue StandardError
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
  end
end
