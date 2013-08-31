require_relative "../repositories/story_repository"

module FeverAPI
  class SyncSavedItemIds
    def initialize(options = {})
      @story_repository = options.fetch(:story_repository){ StoryRepository }
    end

    def call(params = {})
      if params.keys.include?('saved_item_ids')
        { saved_item_ids: saved_item_ids }
      else
        {}
      end
    end

    private

    def saved_item_ids
      all_starred_stories.map{|s| s.id}.join(',')
    end

    def all_starred_stories
      @story_repository.all_starred
    end
  end
end
