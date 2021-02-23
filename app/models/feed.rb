require_relative "./application_record"

class Feed < ApplicationRecord
  has_many :stories, -> { order "published desc" }, dependent: :delete_all
  belongs_to :group

  validates_uniqueness_of :url

  enum status: { green: 0, yellow: 1, red: 2 }

  def status_bubble
    return "yellow" if status == "red" && stories.any?

    status
  end

  def unread_stories
    stories.where("is_read = ?", false)
  end

  def as_fever_json
    {
      id: id,
      favicon_id: 0,
      title: name,
      url: url,
      site_url: url,
      is_spark: 0,
      last_updated_on_time: last_fetched.to_i
    }
  end
end
