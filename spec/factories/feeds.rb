module Factories
  def create_feed(params = {})
    build_feed(params).tap(&:save!)
  end

  def build_feed(params = {})
    Feed.new(url: "https://exampoo.com/#{next_id}", **params)
  end
end
