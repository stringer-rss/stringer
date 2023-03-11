# frozen_string_literal: true

require "nokogiri"

module ExportToOpml
  def self.call(feeds)
    builder =
      Nokogiri::XML::Builder.new do |xml|
        xml.opml(version: "1.0") do
          xml.head { xml.title("Feeds from Stringer") }
          xml.body do
            feeds.each do |feed|
              xml.outline(
                text: feed.name,
                title: feed.name,
                type: "rss",
                xmlUrl: feed.url
              )
            end
          end
        end
      end

    builder.to_xml
  end
end
