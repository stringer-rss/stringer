# frozen_string_literal: true

require "spec_helper"

describe FindNewStories do
  context "the feed contains no new stories" do
    before { allow(StoryRepository).to receive(:exists?).and_return(true) }

    it "finds zero new stories" do
      story1 = double(published: nil, id: "story1")
      story2 = double(published: nil, id: "story2")
      feed   = double(entries: [story1, story2])
      time = Time.zone.local(2013, 1, 2)
      result = described_class.call(feed, 1, time)
      expect(result).to be_empty
    end
  end

  context "the feed contains new stories" do
    it "returns stories that are not found in the database" do
      story1 = double(published: nil, id: "story1")
      story2 = double(published: nil, id: "story2")
      feed   = double(entries: [story1, story2])

      allow(StoryRepository)
        .to receive(:exists?).with("story1", 1).and_return(true)
      allow(StoryRepository)
        .to receive(:exists?).with("story2", 1).and_return(false)

      time = Time.zone.local(2013, 1, 2)
      result = described_class.call(feed, 1, time)
      expect(result).to eq([story2])
    end
  end

  it "scans until matching the last story id" do
    new_story = double(published: nil, id: "new-story")
    old_story = double(published: nil, id: "old-story")
    feed = double(last_modified: nil, entries: [new_story, old_story])

    time = Time.zone.local(2013, 1, 3)
    result = described_class.call(feed, 1, time, "old-story")
    expect(result).to eq([new_story])
  end

  it "ignores stories older than 3 days" do
    new_stories = [
      double(published: 1.hour.ago, id: "new-story"),
      double(published: 2.days.ago, id: "new-story")
    ]

    stories_older_than_3_days = [
      double(published: 3.days.ago, id: "new-story"),
      double(published: 4.days.ago, id: "new-story")
    ]

    feed = double(
      last_modified: nil,
      entries: new_stories + stories_older_than_3_days
    )

    result = described_class.call(feed, 1, nil, nil)
    expect(result).not_to include(stories_older_than_3_days)
  end
end
