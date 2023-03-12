# frozen_string_literal: true

module Feed::ExportToOpml
  class << self
    def call(feeds)
      builder =
        Nokogiri::XML::Builder.new do |xml|
          xml.opml(version: "1.0") do
            xml.head { xml.title("Feeds from Stringer") }
            xml.body { feeds.each { |feed| feed_outline(xml, feed) } }
          end
        end

      builder.to_xml
    end

    private

    def feed_outline(xml, feed)
      xml.outline(
        text: feed.name,
        title: feed.name,
        type: "rss",
        xmlUrl: feed.url
      )
    end
  end
end
