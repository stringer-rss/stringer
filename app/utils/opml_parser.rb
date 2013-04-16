require "nokogiri"

class OpmlParser
  def parse_feeds(contents)
    doc = Nokogiri.XML(contents)

    doc.xpath("//body//outline").inject([]) do |feeds, outline|
      feeds << {
        name: outline.attributes["title"].value,
        url: outline.attributes["xmlUrl"].value
      }
    end
  end
end