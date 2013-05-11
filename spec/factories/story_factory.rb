require_relative "./feed_factory"

class StoryFactory
  class FakeStory < OpenStruct
    def headline
      self.title[0, 50]
    end

    def source
      self.feed.name
    end
  end

  def self.build(params = {})
    FakeStory.new(
      id: rand(100),
      title: params[:title] || Faker::Lorem.sentence, 
      permalink: params[:permalink] || Faker::Internet.url, 
      body: params[:body] || Faker::Lorem.paragraph,
      feed: params[:feed] || FeedFactory.build,
      is_read: params[:is_read] || false,
      published: params[:published] ||Time.now)
  end
end