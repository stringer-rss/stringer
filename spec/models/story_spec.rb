require "spec_helper"
require "support/active_record"

app_require "models/story"

describe "Story" do
  let(:story) do
    Story.new(
      title: Faker::Lorem.sentence(50),
      body: Faker::Lorem.sentence(50)
    )
  end

  describe "#headline" do
    it "truncates to 50 chars" do
      expect(story.headline.size).to eq(50)
    end

    it "uses a fallback string if story has no title" do
      story.title = nil
      expect(story.headline).to eq(Story::UNTITLED)
    end

    it "strips html out" do
      story.title = "<b>Super cool</b> stuff"
      expect(story.headline).to eq "Super cool stuff"
    end
  end

  describe "#lead" do
    it "truncates to 100 chars" do
      expect(story.lead.size).to eq(100)
    end

    it "strips html out" do
      story.body = "<a href='http://github.com'>Yo</a> dawg"
      expect(story.lead).to eq "Yo dawg"
    end
  end

  describe "#source" do
    let(:feed) { Feed.new(name: "Superfeed") }
    before { story.feed = feed }

    it "returns the feeds name" do
      expect(story.source).to eq(feed.name)
    end
  end
end
