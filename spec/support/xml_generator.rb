# frozen_string_literal: true

module XmlGenerator
  def self.call(feed, items)
    Nokogiri::XML::Builder.new do |xml|
      xml.rss(version: "2.0") do
        xml.title(feed.name)
        xml.link(feed.url)
        items.each { |item| build_item(xml, item) }
      end
    end
  end

  def self.build_item(xml, item)
    xml.item do
      xml.title(item.title)
      xml.link(item.url)
      xml.pubDate(item.published)
      xml.content(item.content)
    end
  end
end
