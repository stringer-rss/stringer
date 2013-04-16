require_relative "../../models/feed"
require_relative "../../utils/opml_parser"

class ImportFromOpml
  ONE_HOUR = 60 * 60

  def self.import(opml_contents, should_overwrite = false)
    feeds = OpmlParser.new.parse_feeds(opml_contents)

    Feed.delete_all if should_overwrite

    feeds.each do |feed|
      Feed.create(name: feed[:title],
                  url: feed[:url],
                  last_fetched: Time.now - ONE_HOUR)
    end
  end
end