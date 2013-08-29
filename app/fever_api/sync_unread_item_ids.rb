require_relative "../repositories/story_repository"

module FeverAPI
  class SyncUnreadItemIds
    def call(params)
      if params.keys.include?('unread_item_ids')
        { unread_item_ids: unread_item_ids }
      else
        {}
      end
    end

    private

    def unread_item_ids
      unread_stories.map{|s| s.id}.join(',')
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
