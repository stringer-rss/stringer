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
      story.headline.size.should eq(50)
    end

    it "uses a fallback string if story has no title" do
      story.title = nil
      story.headline.should eq(Story::UNTITLED)
    end

    it "strips html out" do
      story.title = "<b>Super cool</b> stuff"
      story.headline.should eq "Super cool stuff"
    end
  end

  describe "#lead" do
    it "truncates to 100 chars" do
      story.lead.size.should eq(100)
    end

    it "strips html out" do
      story.body = "<a href='http://github.com'>Yo</a> dawg"
      story.lead.should eq "Yo dawg"
    end
  end

  describe "#source" do
    let(:feed) { Feed.new(name: 'Superfeed') }
    before { story.feed = feed }

    it "returns the feeds name" do
      story.source.should eq(feed.name)
    end
  end
end
