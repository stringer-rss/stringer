class Story < ActiveRecord::Base
  belongs_to :feed

  def headline
    self.title
  end

  def lead
    self.body[0,10]
  end

  def source
    self.feed.name
  end
end