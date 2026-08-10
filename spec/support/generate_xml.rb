# frozen_string_literal: true

module GenerateXml
  ITUNES_NAMESPACE = "http://www.itunes.com/dtds/podcast-1.0.dtd"

  class << self
    def call(feed, items)
      build_feed(feed, items).to_xml
    end

    private

    def build_feed(feed, items)
      Nokogiri::XML::Builder.new do |xml|
        xml.rss(**rss_attributes(items)) do
          xml.title(feed.name)
          xml.link(feed.url)
          items.each { |item| build_item(xml, item) }
        end
      end
    end

    # Feedjira only parses enclosures on itunes feeds, so declare the
    # namespace when an item carries one.
    def rss_attributes(items)
      attributes = {
        version: "2.0",
        "xmlns:content" => "http://purl.org/rss/1.0/modules/content/"
      }

      attributes["xmlns:itunes"] = ITUNES_NAMESPACE if enclosures?(items)

      attributes
    end

    def enclosures?(items)
      items.any? { |item| item.try(:enclosure_url) }
    end

    def build_item(xml, item)
      xml.item do
        xml.title(item.title)
        xml.link(item.url)
        xml.guid(item.guid) if item.try(:guid)
        xml.pubDate(item.published)
        xml["content"].encoded(item.content)
        if item.try(:enclosure_url)
          xml.enclosure(url: item.enclosure_url, type: "audio/mpeg", length: 0)
        end
      end
    end
  end
end
