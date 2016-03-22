require_relative "./feed"

class Story < ActiveRecord::Base
  belongs_to :feed

  validates_uniqueness_of :entry_id, scope: :feed_id

  UNTITLED = "[untitled]".freeze

  def headline
    title.nil? ? UNTITLED : strip_html(title)[0, 50]
  end

  def lead
    strip_html(body)[0, 100]
  end

  def source
    feed.name
  end

  def pretty_date
    I18n.l(published)
  end

  def as_json(_options = {})
    super(methods: [:headline, :lead, :source, :pretty_date])
  end

  def as_fever_json
    {
      id: id,
      feed_id: feed_id,
      title: title,
      author: source,
      html: body,
      url: permalink,
      is_saved: is_starred ? 1 : 0,
      is_read: is_read ? 1 : 0,
      created_on_time: published.to_i
    }
  end

  private

  def strip_html(contents)
    Loofah.fragment(contents).text
  end
end
