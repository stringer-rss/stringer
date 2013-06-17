require_relative "../models/story"
require_relative "../utils/sample_story"

class StoryRepository
  def self.add(entry, feed)
    Story.create(feed: feed,
                title: entry.title,
                permalink: entry.url,
                body: extract_content(entry),
                is_read: false,
                is_starred: false,
                published: entry.published || Time.now)
  end

  def self.fetch(id)
    Story.find(id)
  end

  def self.fetch_by_ids(ids)
    Story.where(id: ids)
  end

  def self.save(story)
    story.save
  end

  def self.unread
    Story.where(is_read: false).order("published desc")
  end

  def self.unread_since_id(since_id)
    unread.where('id > ?', since_id)
  end

  def self.read(page = 1)
    Story.where(is_read: true)
      .order("published desc").page(page).per_page(20)
  end

  def self.starred(page = 1)
    Story.where(is_starred: true)
          .order("published desc").page(page).per_page(20)
  end

  def self.read_count
    Story.where(is_read: true).count
  end

  def self.extract_content(entry)
    sanitized_content = ""

    if entry.content
      sanitized_content = entry.content.sanitize
    elsif entry.summary
      sanitized_content = entry.summary.sanitize
    end

    expand_absolute_urls(sanitized_content, entry.url)
  end

  def self.expand_absolute_urls(content, base_url)
    doc = Nokogiri::HTML.fragment(content)
    abs_re = URI::DEFAULT_PARSER.regexp[:ABS_URI]

    [["a", "href"], ["img", "src"], ["video", "src"]].each do |tag, attr|
      doc.css(tag).each do |node|
        url = node.get_attribute(attr)
        unless url =~ abs_re || url.nil?
          node.set_attribute(attr, URI.join(base_url, url).to_s)
        end
      end
    end

    doc.to_html
  end

  def self.samples
    [
      SampleStory.new("Darin' Fireballs", "Why you should trade your firstborn for a Retina iPad"),
      SampleStory.new("TechKrunch", "SugarGlidr raises $1.2M Series A for Social Network for Photo Filters"),
      SampleStory.new("Lambda Da Ultimate", "Flimsy types are the new hotness")
    ]
  end
end

