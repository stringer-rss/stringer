require "nokogiri"

class OpmlParser
  def parse_feeds(contents)
    feeds_with_groups = Hash.new { |h, k| h[k] = [] }

    outlines_in(contents).each do |outline|
      if outline_is_group?(outline)
        group_name = extract_name(outline.attributes).value
        feeds = outline.xpath('./outline')
      else # it's a top-level feed, which means it's a feed without group
        group_name = 'Ungrouped'
        feeds = [outline]
      end

      feeds.each do |feed|
        feeds_with_groups[group_name] << feed_to_hash(feed)
      end
    end

    feeds_with_groups
  end

  private

  def outlines_in(contents)
    Nokogiri.XML(contents).xpath('//body/outline')
  end

  def outline_is_group?(outline)
    outline.attributes['xmlUrl'].nil?
  end

  def extract_name(attributes)
    attributes['title'] || attributes['text']
  end

  def feed_to_hash(feed)
    {
      name: extract_name(feed.attributes).value,
      url:  feed.attributes['xmlUrl'].value
    }
  end
end
