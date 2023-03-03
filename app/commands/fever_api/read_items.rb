# frozen_string_literal: true

module FeverAPI
  module ReadItems
    class << self
      def call(authorization:, **params)
        if params.key?(:items)
          item_ids =
            begin
              params[:with_ids].split(",")
            rescue StandardError
              nil
            end

          {
            items: items(item_ids, params[:since_id], authorization),
            total_items: total_items(item_ids, authorization)
          }
        else
          {}
        end
      end

      private

      def items(item_ids, since_id, authorization)
        items =
          if item_ids
            stories_by_ids(item_ids, authorization)
          else
            unread_stories(since_id, authorization)
          end
        items.map(&:as_fever_json)
      end

      def total_items(item_ids, authorization)
        items =
          if item_ids
            stories_by_ids(item_ids, authorization)
          else
            unread_stories(nil, authorization)
          end
        items.count
      end

      def stories_by_ids(ids, authorization)
        authorization.scope(StoryRepository.fetch_by_ids(ids))
      end

      def unread_stories(since_id, authorization)
        if since_id
          authorization.scope(StoryRepository.unread_since_id(since_id))
        else
          authorization.scope(StoryRepository.unread)
        end
      end
    end
  end
end
