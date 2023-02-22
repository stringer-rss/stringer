# frozen_string_literal: true

require_relative "../../models/feed"
require_relative "../../models/group"
require_relative "../../utils/opml_parser"

module ImportFromOpml
  class << self
    def call(opml_contents, user:)
      feeds_with_groups = OpmlParser.new.parse_feeds(opml_contents)

      # It considers a situation when feeds are already imported without
      # groups, so it's possible to re-import the same subscriptions.xml just
      # to set group_id for existing feeds. Feeds without groups are in
      # 'Ungrouped' group, we don't create such group and create such feeds
      # with group_id = nil.
      feeds_with_groups.each do |group_name, parsed_feeds|
        unless group_name == "Ungrouped"
          group = Group.where(name: group_name).first_or_create
        end

        parsed_feeds.each do |parsed_feed|
          create_feed(parsed_feed, group, user)
        end
      end
    end

    private

    def create_feed(parsed_feed, group, user)
      feed = Feed.where(
        **parsed_feed.slice(:name, :url),
        user_id: [nil, user.id]
      ).first_or_initialize
      feed.user = user
      feed.last_fetched = 1.day.ago if feed.new_record?
      feed.group_id = group.id if group
      feed.save
    end
  end
end
