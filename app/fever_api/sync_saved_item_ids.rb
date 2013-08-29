require_relative "../models/story"

module FeverAPI
  class SyncSavedItemIds
    def call(params)
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
      Story.where(is_starred: true)
    end
  end
end
