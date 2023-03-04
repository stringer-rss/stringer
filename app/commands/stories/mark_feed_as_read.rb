# frozen_string_literal: true

module MarkFeedAsRead
  def self.call(feed_id, timestamp)
    StoryRepository
      .fetch_unread_for_feed_by_timestamp(feed_id, timestamp)
      .update_all(is_read: true)
  end
end
