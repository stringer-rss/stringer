# frozen_string_literal: true

module FeverAPI
  class ReadFeedsGroups
    class << self
      def call(params)
        if params.key?(:feeds) || params.key?(:groups)
          { feeds_groups: }
        else
          {}
        end
      end

      private

      def feeds_groups
        grouped_feeds =
          FeedRepository.in_group.order("LOWER(name)").group_by(&:group_id)
        grouped_feeds.map do |group_id, feeds|
          {
            group_id:,
            feed_ids: feeds.map(&:id).join(",")
          }
        end
      end
    end
  end
end
