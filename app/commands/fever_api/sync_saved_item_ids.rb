# frozen_string_literal: true

module FeverAPI::SyncSavedItemIds
  class << self
    def call(authorization:, **params)
      if params.key?(:saved_item_ids)
        { saved_item_ids: saved_item_ids(authorization) }
      else
        {}
      end
    end

    private

    def saved_item_ids(authorization)
      all_starred_stories(authorization).map(&:id).join(",")
    end

    def all_starred_stories(authorization)
      authorization.scope(StoryRepository.all_starred)
    end
  end
end
