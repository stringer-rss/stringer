require_relative "../../models/feed"
require_relative "../../models/group"
require_relative "../../utils/opml_parser"

class ImportFromOpml
  ONE_DAY = 24 * 60 * 60

  class << self
    def import(opml_contents)
      feeds_with_groups = OpmlParser.new.parse_feeds(opml_contents)

      # It considers a situation when feeds are already imported without groups,
      # so it's possible to re-import the same subscriptions.xml just to set group_id
      # for existing feeds. Feeds without groups are in 'Ungrouped' group, we don't
      # create such group and create such feeds with group_id = nil.
      feeds_with_groups.each do |group_name, parsed_feeds|
        next if parsed_feeds.empty?

        group = Group.where(name: group_name).first_or_create unless group_name == "Ungrouped"

        parsed_feeds.each { |parsed_feed| create_feed(parsed_feed, group) }
      end
    end

    private

    def create_feed(parsed_feed, group)
      feed = Feed.where(name: parsed_feed[:name], url: parsed_feed[:url]).first_or_initialize
      feed.last_fetched = Time.now - ONE_DAY if feed.new_record?
      feed.group_id = group.id if group
      feed.save
    end
  end
end
