# frozen_string_literal: true

module MarkGroupAsRead
  KINDLING_GROUP_ID = 0
  SPARKS_GROUP_ID   = -1

  def self.call(group_id, timestamp)
    return unless group_id

    if [KINDLING_GROUP_ID, SPARKS_GROUP_ID].include?(group_id.to_i)
      StoryRepository
        .fetch_unread_by_timestamp(timestamp).update_all(is_read: true)
    else
      StoryRepository
        .fetch_unread_by_timestamp_and_group(timestamp, group_id)
        .update_all(is_read: true)
    end
  end
end
