# frozen_string_literal: true

class Feed < ApplicationRecord
  has_many :stories, -> { order(published: :desc) }, dependent: :delete_all
  has_many :unread_stories, -> { unread }, class_name: "Story"
  belongs_to :group
  belongs_to :user

  delegate :name, to: :group, prefix: true, allow_nil: true

  validates :url, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, presence: true

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
end
