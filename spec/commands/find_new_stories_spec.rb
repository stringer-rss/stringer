require "spec_helper"

app_require "commands/feeds/find_new_stories"

describe FindNewStories do
  describe "#new_stories" do
    context "the feed has not been updated" do
      it "should find zero new stories" do
        feed = stub(last_modified: Time.new(2013, 1, 1))

        result = FindNewStories.new(feed, Time.new(2013, 1, 2)).new_stories
        result.should be_empty
      end
    end

    context "the feed has been updated" do
      it "should return stories that are new based on published date" do
        new_story = stub(published: Time.new(2013, 1, 5))
        old_story = stub(published: Time.new(2013, 1, 1))
        feed = stub(last_modified: Time.new(2013, 1, 5), entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3)).new_stories
        result.should eq [new_story]
      end
    end

    context "the feed does not report last_modified" do
      it "should check all stories and compare published time" do
        new_story = stub(published: Time.new(2013, 1, 5))
        old_story = stub(published: Time.new(2013, 1, 1))
        feed = stub(last_modified: nil, entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3)).new_stories
        result.should eq [new_story]
      end
    end

    context "the feed has no timekeeping" do
      it "should scan until matching the last entry_id" do
        new_story = stub(published: nil, entry_id: "new-story")
        old_story = stub(published: nil, entry_id: "old-story")
        feed = stub(last_modified: nil, entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3), old_story).new_stories
        result.should eq [new_story]
      end

      it "should scan until matching the last url" do
        new_story = stub(published: nil, entry_id: nil, url: "http://blog.com/new-story")
        old_story = stub(published: nil, entry_id: nil, url: "http://blog.com/old-story", permalink: "http://blog.com/old-story")
        feed = stub(last_modified: nil, entries: [new_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3), old_story).new_stories
        result.should eq [new_story]
      end

      it "should prefer scanning until the last entry_id over the last url" do
        new_story = stub(published: nil, entry_id: "new-story", url: "http://blog.com/new-story")
        duplicate_id_story = stub(published: nil, entry_id: "duplicate-id-story-story", permalink: "http://blog.com/new-story")
        old_story = stub(published: nil, entry_id: "old-story", permalink: "http://blog.com/old-story")
        feed = stub(last_modified: nil, entries: [new_story, duplicate_id_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3), duplicate_id_story).new_stories
        result.should eq [new_story]
      end

      it "should not import new stories if they have the same url as a previous one when they have no entry_id" do
        new_story = stub(published: nil, entry_id: nil, url: "http://blog.com/new-story")
        duplicate_id_story = stub(published: nil, entry_id: nil, permalink: "http://blog.com/new-story")
        old_story = stub(published: nil, entry_id: nil, permalink: "http://blog.com/old-story")
        feed = stub(last_modified: nil, entries: [new_story, duplicate_id_story, old_story])

        result = FindNewStories.new(feed, Time.new(2013, 1, 3), duplicate_id_story).new_stories
        result.should eq []
      end
    end
  end
end
