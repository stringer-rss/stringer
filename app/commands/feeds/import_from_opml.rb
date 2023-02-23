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
        group = find_or_create_group(group_name, user)

        parsed_feeds.each do |parsed_feed|
          create_feed(parsed_feed, group, user)
        end
      end
    end

    private

    def find_or_create_group(group_name, user)
      return if group_name == "Ungrouped"

      user.groups.create_or_find_by(name: group_name)
    end

    def create_feed(parsed_feed, group, user)
      feed = user.feeds.where(**parsed_feed.slice(:name, :url))
                 .first_or_initialize
      feed.last_fetched = 1.day.ago if feed.new_record?
      feed.group_id = group.id if group
      feed.save
    end
  end
end
