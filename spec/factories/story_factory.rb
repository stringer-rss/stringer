require_relative "./feed_factory"

class StoryFactory
  class FakeStory < OpenStruct
    def headline
      self.title[0, 50]
    end

    def source
      self.feed.name
    end

    def as_fever_json
      {
        id: self.id,
        feed_id: self.feed_id,
        title: self.title,
        author: source,
        html: body,
        url: self.permalink,
        is_saved: self.is_starred ? 1 : 0,
        is_read: self.is_read ? 1 : 0,
        created_on_time: self.published.to_i
      }
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
      is_starred: params[:is_starred] || false,
      published: params[:published] ||Time.now)
  end
end
