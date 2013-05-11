class Feed < ActiveRecord::Base
  has_many :stories, order: "published desc", dependent: :delete_all

  validates_uniqueness_of :url

  STATUS = { green: 0, yellow: 1, red: 2 }

  STATUS_TEXT = { green: "Success!", 
                  yellow: "Error parsing (probably temporary)", 
                  red: "Error parsing (and it ain't never worked before, either)" }

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

  def status_bubble_text
    STATUS_TEXT[status_bubble]
  end
end