require "nokogiri"

class OpmlParser
  def parse_feeds(contents)
    doc = Nokogiri.XML(contents)

    feeds_with_groups = Hash.new { |h,k| h[k] = [] }

    doc.xpath('//body/outline').each do |outline|

      if outline.attributes['xmlUrl'].nil? # it's a group!
        group_name = extract_name(outline.attributes).value
        feeds = outline.xpath('./outline')
      else # it's a top-level feed, which means it's a feed without group
        group_name = 'Ungrouped'
        feeds = [outline]
      end

      feeds.each do |feed|
        feeds_with_groups[group_name] << { name: extract_name(feed.attributes).value,
                                           url:  feed.attributes['xmlUrl'].value }
      end
    end
    feeds_with_groups
  end

  private

  def extract_name(attributes)
    attributes['title'] || attributes['text']
  end
end
