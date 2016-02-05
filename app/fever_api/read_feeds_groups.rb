require_relative "../repositories/feed_repository"

module FeverAPI
  class ReadFeedsGroups
    def initialize(options = {})
      @feed_repository = options.fetch(:feed_repository) { FeedRepository }
    end

    def call(params = {})
      if params.keys.include?("feeds") || params.keys.include?("groups")
        { feeds_groups: feeds_groups }
      else
        {}
      end
    end

    private

    def feeds_groups
      grouped_feeds = @feed_repository.in_group.order("LOWER(name)")
                      .group_by(&:group_id)
      grouped_feeds.map do |group_id, feeds|
        {
          group_id: group_id,
          feed_ids: feeds.map(&:id).join(",")
        }
      end
    end
  end
end
