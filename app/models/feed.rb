# frozen_string_literal: true

class Feed < ApplicationRecord
  has_many :stories, -> { order(published: :desc) }, dependent: :delete_all
  has_many :unread_stories, -> { unread }, class_name: "Story"
  belongs_to :group
  belongs_to :user

  delegate :name, to: :group, prefix: true, allow_nil: true

  validates :url, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  # Only on change, so rows stored before this validation existed can still
  # record status and last_fetched updates.
  validate :url_scheme_is_allowed, if: :url_changed?

  enum :status, { green: 0, yellow: 1, red: 2 }

  scope :with_unread_stories_counts,
        lambda {
          left_joins(:unread_stories)
            .select("feeds.*, count(stories.id) as unread_stories_count")
            .group("feeds.id")
        }

  def status_bubble
    return "yellow" if status == "red" && stories.any?

    status
  end

  def as_fever_json
    {
      id:,
      favicon_id: 0,
      title: name || "",
      url:,
      site_url: url,
      is_spark: 0,
      last_updated_on_time: last_fetched.to_i
    }
  end

  private

  # Mirrors SafeFetch so we never store a url we would refuse to fetch. This
  # also keeps `javascript:` out of the feed link rendered on /feeds and out
  # of the urls handed to Fever clients and OPML exports.
  def url_scheme_is_allowed
    return if url.blank?
    return if SafeFetch::ALLOWED_SCHEMES.include?(SafeFetch.scheme(url))

    errors.add(:url, "must be an http or https address")
  end
end
