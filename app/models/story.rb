require_relative "./feed"

class Story < ActiveRecord::Base
  belongs_to :feed

  validates_uniqueness_of :permalink, :scope => :feed_id

  UNTITLED = "[untitled]"

  def headline
    self.title.nil? ? UNTITLED : self.title[0, 50]
  end

  def lead
    Loofah.fragment(self.body).text[0,100]
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
end