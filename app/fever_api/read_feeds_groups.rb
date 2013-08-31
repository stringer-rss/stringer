require_relative "../repositories/feed_repository"

module FeverAPI
  class ReadFeedsGroups
    def initialize(options = {})
      @feed_repository = options.fetch(:feed_repository){ FeedRepository }
    end

    def call(params = {})
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
          feed_ids: feeds.map{|f| f.id}.join(",")
        }
      ]
    end

    def feeds
      @feed_repository.list
    end
  end
end
