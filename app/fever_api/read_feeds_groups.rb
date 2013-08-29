require_relative "../models/feed"

module FeverAPI
  class ReadFeedsGroups
    def call(params)
      if params.keys.include?('feeds') || params.keys.include?('groups')
        { feeds_groups: feeds_groups }
      else
        {}
      end
    end

    private

    def feeds_groups
      [
        {
          group_id: 1,
          feed_ids: Feed.all.map{|f| f.id}.join(",")
        }
      ]
    end
  end
end
