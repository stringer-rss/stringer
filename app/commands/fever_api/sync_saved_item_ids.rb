# frozen_string_literal: true

module FeverAPI
  module SyncSavedItemIds
    class << self
      def call(params)
        if params.keys.include?("saved_item_ids")
          { saved_item_ids: }
        else
          {}
        end
      end

      private

      def saved_item_ids
        all_starred_stories.map(&:id).join(",")
      end

      def all_starred_stories
        StoryRepository.all_starred
      end
    end
  end
end
