# frozen_string_literal: true

module FeverAPI::SyncUnreadItemIds
  class << self
    def call(authorization:, **params)
      if params.key?(:unread_item_ids)
        { unread_item_ids: unread_item_ids(authorization) }
      else
        {}
      end
    end

    private

    def unread_item_ids(authorization)
      authorization.scope(unread_stories).map(&:id).join(",")
    end

    def unread_stories
      StoryRepository.unread
    end
  end
end
