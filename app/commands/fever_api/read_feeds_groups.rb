# frozen_string_literal: true

class FeverAPI::ReadFeedsGroups
  class << self
    def call(authorization:, **params)
      if params.key?(:feeds) || params.key?(:groups)
        { feeds_groups: feeds_groups(authorization) }
      else
        {}
      end
    end

    private

    def feeds_groups(authorization)
      scoped_feeds = authorization.scope(FeedRepository.list)
      grouped_feeds = scoped_feeds.order("LOWER(name)").group_by(&:group_id)
      grouped_feeds.map do |group_id, feeds|
        group_id ||= Group::UNGROUPED.id

        {
          group_id:,
          feed_ids: feeds.map(&:id).join(",")
        }
      end
    end
  end
end
