require "nokogiri"

class ExportToOpml
  def initialize(feeds)
    @feeds = feeds
  end

  def to_xml # rubocop:disable Metrics/MethodLength
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.opml(version: "1.0") do
        xml.head do
          xml.title "Feeds from Stringer"
        end
        xml.body do
          @feeds.each do |feed|
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
