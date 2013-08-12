require_relative "./feed"

class Story < ActiveRecord::Base
  belongs_to :feed

  validates_uniqueness_of :entry_id, scope: :feed_id

  UNTITLED = "[untitled]"

  def headline
    self.title.nil? ? UNTITLED : strip_html(self.title)[0, 50]
  end

  def lead
    strip_html(self.body)[0,100]
  end

  def source
    self.feed.name
  end

  def pretty_date
    I18n.l(self.published)
  end

  def as_json(options = {})
    super(methods: [:headline, :lead, :source, :pretty_date])
  end

  def as_fever_json
    {
      id: self.id,
      feed_id: self.feed_id,
      title: self.title,
      author: source,
      html: body,
      url: self.permalink,
      is_saved: self.is_starred ? 1 : 0,
      is_read: self.is_read ? 1 : 0,
      created_on_time: self.published.to_i
    }
  end

  private
  def strip_html(contents)
    Loofah.fragment(contents).text
  end
end
