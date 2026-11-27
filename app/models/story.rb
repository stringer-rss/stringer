# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :feed
  has_one :user, through: :feed

  validates_uniqueness_of :entry_id, scope: :feed_id

  delegate :group_id, :user_id, to: :feed

  scope :unread, -> { where(is_read: false) }

  UNTITLED = "[untitled]"

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

  def as_fever_json
    {
      id:,
      feed_id:,
      title:,
      author: source,
      html: body,
      url: permalink,
      is_saved: is_starred ? 1 : 0,
      is_read: is_read ? 1 : 0,
      created_on_time: published.to_i
    }
  end

  private

  # Plain text, not HTML: views escape it when they render it.
  def strip_html(contents)
    Loofah.fragment(contents).text(encode_special_chars: false)
  end
end
