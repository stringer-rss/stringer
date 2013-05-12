class Feed < ActiveRecord::Base
  has_many :stories, order: "published desc", dependent: :delete_all

  validates_uniqueness_of :url

  STATUS = { green: 0, yellow: 1, red: 2 }

  def status
    STATUS.key(read_attribute(:status))
  end

  def status=(s)
    write_attribute(:status, STATUS[s])
  end

  def status_bubble
    return :yellow if status == :red && stories.any?
    status
  end
end