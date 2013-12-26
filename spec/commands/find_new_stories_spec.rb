require "spec_helper"

app_require "commands/feeds/find_new_stories"

describe FindNewStories do
  describe "#new_stories" do
    context "the feed has not been updated" do
      it "should find zero new stories" do
        feed = double(last_modified: Time.new(2013, 1, 1))

        result = FindNewStories.new(feed, Time.new(2013, 1, 2)).new_stories
        result.should be_empty
      end
    end

    context "the feed has been updated" do
      it "should return stories that are new based on published date" do
        new_story = double(published: Time.new(2013, 1, 5))
        old_story = double(published: Time.new(2013, 1, 1))
        feed = double(last_modified: Time.new(2013, 1, 5), entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3)).new_stories
        result.should eq [new_story]
      end
    end

    context "the feed does not report last_modified" do
      it "should check all stories and compare published time" do
        new_story = double(published: Time.new(2013, 1, 5))
        old_story = double(published: Time.new(2013, 1, 1))
        feed = double(last_modified: nil, entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3)).new_stories
        result.should eq [new_story]
      end
    end

    context "the feed has no timekeeping" do
      it "should scan until matching the last story id" do
        new_story = double(published: nil, id: "new-story")
        old_story = double(published: nil, id: "old-story")
        feed = double(last_modified: nil, entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3), "old-story").new_stories
        result.should eq [new_story]
      end
    end
  end
end
