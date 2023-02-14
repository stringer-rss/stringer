# frozen_string_literal: true

module FeverAPI
  class SyncUnreadItemIds
    def self.call(params)
      new.call(params)
    end

    def initialize(options = {})
      @story_repository = options.fetch(:story_repository) { StoryRepository }
    end

    def call(params = {})
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
      @story_repository.unread
    end
  end
end
