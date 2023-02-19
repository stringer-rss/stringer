# frozen_string_literal: true

module FeverAPI
  module SyncUnreadItemIds
    class << self
      def call(params)
        if params.keys.include?("unread_item_ids")
          { unread_item_ids: }
        else
          {}
        end
      end

      private

      def unread_item_ids
        unread_stories.map(&:id).join(",")
      end

      def unread_stories
        StoryRepository.unread
      end
    end
  end
end
