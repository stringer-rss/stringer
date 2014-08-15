require "spec_helper"

app_require "repositories/story_repository"
app_require "commands/feeds/find_new_stories"

describe FindNewStories do
  describe "#new_stories" do
    context "the feed contains no new stories" do
      before do
        StoryRepository.stub(:exists?).and_return(true)
      end

      it "should find zero new stories" do
        story1 = double(id: "story1")
        story2 = double(id: "story2")
        feed   = double(entries: [story1, story2])

        result = FindNewStories.new(feed, 1, Time.new(2013, 1, 2)).new_stories
        result.should be_empty
      end
    end

    context "the feed contains new stories" do
      it "should return stories that are not found in the database" do
        story1 = double(id: "story1")
        story2 = double(id: "story2")
        feed   = double(entries: [story1, story2])

        StoryRepository.stub(:exists?).with("story1", 1).and_return(true)
        StoryRepository.stub(:exists?).with("story2", 1).and_return(false)

        result = FindNewStories.new(feed, 1, Time.new(2013, 1, 2)).new_stories
        result.should eq [story2]
      end
    end

    it "should scan until matching the last story id" do
      new_story = double(published: nil, id: "new-story")
      old_story = double(published: nil, id: "old-story")
      feed = double(last_modified: nil, entries: [new_story, old_story])

      result = FindNewStories.new(feed, 1, Time.new(2013, 1, 3), "old-story").new_stories
      result.should eq [new_story]
    end
  end
end
