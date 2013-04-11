class Story < ActiveRecord::Base
  belongs_to :feed

  def headline
    self.title[0, 50]
  end

  def lead
    Loofah.fragment(self.body).text[0,25]
  end

  def source
    self.feed.name
  end
end