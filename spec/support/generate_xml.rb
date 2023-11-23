# frozen_string_literal: true

module GenerateXml
  class << self
    def call(feed, items)
      build_feed(feed, items).to_xml
    end

    private

    def build_feed(feed, items)
      Nokogiri::XML::Builder.new do |xml|
        xml.rss(version: "2.0") do
          xml.title(feed.name)
          xml.link(feed.url)
          items.each { |item| build_item(xml, item) }
        end
      end
    end

    def build_item(xml, item)
      xml.item do
        xml.title(item.title)
        xml.link(item.url)
        xml.pubDate(item.published)
        xml.content(item.content)
      end
    end
  end
end
