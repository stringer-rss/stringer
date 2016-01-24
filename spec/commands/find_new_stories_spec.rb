require "spec_helper"

app_require "repositories/story_repository"
app_require "commands/feeds/find_new_stories"

describe FindNewStories do
  describe "#new_stories" do
    context "the feed contains no new stories" do
      before do
        allow(StoryRepository).to receive(:exists?).and_return(true)
      end

      it "should find zero new stories" do
        story1 = double(published: nil, id: "story1")
        story2 = double(published: nil, id: "story2")
        feed   = double(entries: [story1, story2])

        result = FindNewStories.new(feed, 1, Time.new(2013, 1, 2)).new_stories
        expect(result).to be_empty
      end
    end

    context "the feed contains new stories" do
      it "should return stories that are not found in the database" do
        story1 = double(published: nil, id: "story1")
        story2 = double(published: nil, id: "story2")
        feed   = double(entries: [story1, story2])

        allow(StoryRepository).to receive(:exists?).with("story1", 1).and_return(true)
        allow(StoryRepository).to receive(:exists?).with("story2", 1).and_return(false)

        result = FindNewStories.new(feed, 1, Time.new(2013, 1, 2)).new_stories
        expect(result).to eq [story2]
      end
    end

    it "should scan until matching the last story id" do
      new_story = double(published: nil, id: "new-story")
      old_story = double(published: nil, id: "old-story")
      feed = double(last_modified: nil, entries: [new_story, old_story])

      result = FindNewStories.new(feed, 1, Time.new(2013, 1, 3), "old-story").new_stories
      expect(result).to eq [new_story]
    end

    it "should ignore stories older than 3 days" do
      new_stories = [
        double(published: 1.hour.ago, id: "new-story"),
        double(published: 2.days.ago, id: "new-story")
      ]

      stories_older_than_3_days = [
        double(published: 3.days.ago, id: "new-story"),
        double(published: 4.days.ago, id: "new-story")
      ]

      feed = double(last_modified: nil, entries: new_stories + stories_older_than_3_days)

      result = FindNewStories.new(feed, 1, nil, nil).new_stories
      expect(result).not_to include(stories_older_than_3_days)
    end
  end
end
