require "nokogiri"

class OpmlParser
  def parse_feeds(contents)
    doc = Nokogiri.XML(contents)

    doc.xpath("//body//outline").inject([]) do |feeds, outline|
      next feeds if missing_fields? outline.attributes

      feeds << {
        name: outline.attributes["title"].value,
        url: outline.attributes["xmlUrl"].value
      }
    end
  end

  private
  def missing_fields?(attributes)
    attributes["xmlUrl"].nil? || attributes["title"].nil?
  end
end