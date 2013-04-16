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

  def self.build
    FakeStory.new(
      id: rand(100),
      title: Faker::Lorem.sentence, 
      permalink: Faker::Internet.url, 
      body: Faker::Lorem.paragraph,
      feed: FeedFactory.build,
      is_read: false,
      published: Time.now)
  end
end