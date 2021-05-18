require "spec_helper"
require "support/active_record"

app_require "repositories/story_repository"

describe StoryRepository do
  describe ".add" do
    let(:feed) { double(url: "http://blog.golang.org/feed.atom") }
    before do
      allow(Story).to receive(:create)
    end

    it "normalizes story urls" do
      entry = double(url: "//blog.golang.org/context", title: "", content: "").as_null_object
      expect(StoryRepository).to receive(:normalize_url).with(entry.url, feed.url)

      StoryRepository.add(entry, feed)
    end

    it "deletes line and paragraph separator characters from titles" do
      entry = double(title: "n\u2028\u2029", content: "").as_null_object
      allow(StoryRepository).to receive(:normalize_url)

      expect(Story).to receive(:create).with(hash_including(title: "n"))

      StoryRepository.add(entry, feed)
    end

    it "deletes script tags from titles" do
      entry = double(title: "n<script>alert('xss');</script>", content: "").as_null_object
      allow(StoryRepository).to receive(:normalize_url)

      expect(Story).to receive(:create).with(hash_including(title: "n"))

      StoryRepository.add(entry, feed)
    end
  end

  describe ".fetch" do
    it "finds the story by id" do
      story = create_story

      expect(StoryRepository.fetch(story.id)).to eq(story)
    end
  end

  describe ".fetch_by_ids" do
    it "finds all stories by id" do
      story1 = create_story
      story2 = create_story
      expected_stories = [story1, story2]

      actual_stories = StoryRepository.fetch_by_ids(expected_stories.map(&:id))

      expect(actual_stories).to match_array(expected_stories)
    end
  end

  describe ".fetch_unread_by_timestamp" do
    it "returns unread stories from before the timestamp" do
      story = create_story(created_at: 1.week.ago, is_read: false)

      actual_stories = StoryRepository.fetch_unread_by_timestamp(4.days.ago)

      expect(actual_stories).to eq([story])
    end

    it "does not return unread stories from after the timestamp" do
      create_story(created_at: 3.days.ago, is_read: false)

      actual_stories = StoryRepository.fetch_unread_by_timestamp(4.days.ago)

      expect(actual_stories).to be_empty
    end

    it "does not return read stories from before the timestamp" do
      create_story(created_at: 1.week.ago, is_read: true)

      actual_stories = StoryRepository.fetch_unread_by_timestamp(4.days.ago)

      expect(actual_stories).to be_empty
    end
  end

  describe ".fetch_unread_by_timestamp_and_group" do
    it "returns unread stories before timestamp for group_id" do
      feed = create_feed(group_id: 52)
      story = create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = Time.now

      stories = StoryRepository.fetch_unread_by_timestamp_and_group(time, 52)

      expect(stories).to eq([story])
    end

    it "does not return read stories before timestamp for group_id" do
      feed = create_feed(group_id: 52)
      create_story(feed: feed, created_at: 5.minutes.ago)
      time = Time.now

      stories = StoryRepository.fetch_unread_by_timestamp_and_group(time, 52)

      expect(stories).to be_empty
    end

    it "does not return unread stories after timestamp for group_id" do
      feed = create_feed(group_id: 52)
      create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = 6.minutes.ago

      stories = StoryRepository.fetch_unread_by_timestamp_and_group(time, 52)

      expect(stories).to be_empty
    end

    it "does not return stories before timestamp for other group_id" do
      feed = create_feed(group_id: 52)
      create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = Time.now

      stories = StoryRepository.fetch_unread_by_timestamp_and_group(time, 55)

      expect(stories).to be_empty
    end

    it "does not return stories with no group_id before timestamp" do
      feed = create_feed
      create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = Time.now

      stories = StoryRepository.fetch_unread_by_timestamp_and_group(time, 52)

      expect(stories).to be_empty
    end

    it "returns unread stories before timestamp for nil group_id" do
      feed = create_feed
      story = create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = Time.now

      stories = StoryRepository.fetch_unread_by_timestamp_and_group(time, nil)

      expect(stories).to eq([story])
    end
  end

  describe ".fetch_unread_for_feed_by_timestamp" do
    it "returns unread stories for the feed before timestamp" do
      feed = create_feed
      story = create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = 4.minutes.ago

      stories =
        StoryRepository.fetch_unread_for_feed_by_timestamp(feed.id, time)

      expect(stories).to eq([story])
    end

    it "returns unread stories for the feed before string timestamp" do
      feed = create_feed
      story = create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      timestamp = Integer(4.minutes.ago).to_s

      stories =
        StoryRepository.fetch_unread_for_feed_by_timestamp(feed.id, timestamp)

      expect(stories).to eq([story])
    end

    it "does not return read stories for the feed before timestamp" do
      feed = create_feed
      create_story(feed: feed, created_at: 5.minutes.ago)
      time = 4.minutes.ago

      stories =
        StoryRepository.fetch_unread_for_feed_by_timestamp(feed.id, time)

      expect(stories).to be_empty
    end

    it "does not return unread stories for the feed after timestamp" do
      feed = create_feed
      create_story(:unread, feed: feed, created_at: 5.minutes.ago)
      time = 6.minutes.ago

      stories =
        StoryRepository.fetch_unread_for_feed_by_timestamp(feed.id, time)

      expect(stories).to be_empty
    end

    it "does not return unread stories for another feed before timestamp" do
      feed = create_feed
      create_story(:unread, created_at: 5.minutes.ago)
      time = 4.minutes.ago

      stories =
        StoryRepository.fetch_unread_for_feed_by_timestamp(feed.id, time)

      expect(stories).to be_empty
    end
  end

  describe ".unread" do
    it "returns unread stories ordered by published date descending" do
      story1 = create_story(:unread, published: 5.minutes.ago)
      story2 = create_story(:unread, published: 4.minutes.ago)

      expect(StoryRepository.unread).to eq([story2, story1])
    end

    it "does not return read stories" do
      create_story(published: 5.minutes.ago)
      create_story(published: 4.minutes.ago)

      expect(StoryRepository.unread).to be_empty
    end
  end

  describe ".unread_since_id" do
    it "returns unread stories with id greater than given id" do
      story1 = create_story(:unread)
      story2 = create_story(:unread)

      expect(StoryRepository.unread_since_id(story1.id)).to eq([story2])
    end

    it "does not return read stories with id greater than given id" do
      story1 = create_story(:unread)
      create_story

      expect(StoryRepository.unread_since_id(story1.id)).to be_empty
    end

    it "does not return unread stories with id less than given id" do
      create_story(:unread)
      story2 = create_story(:unread)

      expect(StoryRepository.unread_since_id(story2.id)).to be_empty
    end
  end

  describe ".feed" do
    it "returns stories for the given feed id" do
      feed = create_feed
      story = create_story(feed: feed)

      expect(StoryRepository.feed(feed.id)).to eq([story])
    end

    it "sorts stories by published" do
      feed = create_feed
      story1 = create_story(feed: feed, published: 1.day.ago)
      story2 = create_story(feed: feed, published: 1.hour.ago)

      expect(StoryRepository.feed(feed.id)).to eq([story2, story1])
    end

    it "does not return stories for other feeds" do
      feed = create_feed
      create_story

      expect(StoryRepository.feed(feed.id)).to be_empty
    end
  end

  describe ".read" do
    it "returns read stories" do
      story = create_story(:read)

      expect(StoryRepository.read).to eq([story])
    end

    it "sorts stories by published" do
      story1 = create_story(:read, published: 1.day.ago)
      story2 = create_story(:read, published: 1.hour.ago)

      expect(StoryRepository.read).to eq([story2, story1])
    end

    it "does not return unread stories" do
      create_story(:unread)

      expect(StoryRepository.read).to be_empty
    end

    it "paginates results" do
      stories =
        21.times.map { |num| create_story(:read, published: num.days.ago) }

      expect(StoryRepository.read).to eq(stories[0...20])
      expect(StoryRepository.read(2)).to eq([stories.last])
    end
  end

  describe ".starred" do
    it "returns starred stories" do
      story = create_story(:starred)

      expect(StoryRepository.starred).to eq([story])
    end

    it "sorts stories by published" do
      story1 = create_story(:starred, published: 1.day.ago)
      story2 = create_story(:starred, published: 1.hour.ago)

      expect(StoryRepository.starred).to eq([story2, story1])
    end

    it "does not return unstarred stories" do
      create_story

      expect(StoryRepository.starred).to be_empty
    end

    it "paginates results" do
      stories =
        21.times.map { |num| create_story(:starred, published: num.days.ago) }

      expect(StoryRepository.starred).to eq(stories[0...20])
      expect(StoryRepository.starred(2)).to eq([stories.last])
    end
  end

  describe ".unstarred_read_stories_older_than" do
    it "returns unstarred read stories older than given number of days" do
      story = create_story(:read, published: 6.days.ago)

      expect(StoryRepository.unstarred_read_stories_older_than(5)).to eq([story])
    end

    it "does not return starred stories older than the given number of days" do
      create_story(:read, :starred, published: 6.days.ago)

      expect(StoryRepository.unstarred_read_stories_older_than(5)).to be_empty
    end

    it "does not return unread stories older than the given number of days" do
      create_story(:unread, published: 6.days.ago)

      expect(StoryRepository.unstarred_read_stories_older_than(5)).to be_empty
    end

    it "does not return stories newer than given number of days" do
      create_story(:read, published: 4.days.ago)

      expect(StoryRepository.unstarred_read_stories_older_than(5)).to be_empty
    end
  end

  describe ".read_count" do
    it "returns the count of read stories" do
      create_story(:read)
      create_story(:read)
      create_story(:read)

      expect(StoryRepository.read_count).to eq(3)
    end

    it "does not count unread stories" do
      create_story(:unread)
      create_story(:unread)
      create_story(:unread)

      expect(StoryRepository.read_count).to eq(0)
    end
  end

  describe ".extract_url" do
    it "returns the url" do
      feed = double(url: "http://github.com")
      entry = double(url: "https://github.com/swanson/stringer")

      expect(StoryRepository.extract_url(entry, feed)).to eq "https://github.com/swanson/stringer"
    end

    it "returns the enclosure_url when the url is nil" do
      feed = double(url: "http://github.com")
      entry = double(url: nil, enclosure_url: "https://github.com/swanson/stringer")

      expect(StoryRepository.extract_url(entry, feed)).to eq "https://github.com/swanson/stringer"
    end

    it "does not crash if url is nil but enclosure_url does not exist" do
      feed = double(url: "http://github.com")
      entry = double(url: nil)

      expect(StoryRepository.extract_url(entry, feed)).to eq nil
    end
  end

  describe ".extract_title" do
    let(:entry) do
    end

    it "returns the title if there is a title" do
      entry = double(title: "title", summary: "summary")

      expect(StoryRepository.extract_title(entry)).to eq "title"
    end

    it "returns the summary if there isn't a title" do
      entry = double(title: "", summary: "summary")

      expect(StoryRepository.extract_title(entry)).to eq "summary"
    end
  end

  describe ".extract_content" do
    let(:entry) do
      double(url: "http://mdswanson.com",
             content: "Some test content<script></script>")
    end

    let(:summary_only) do
      double(url: "http://mdswanson.com",
             content: nil,
             summary: "Dumb publisher")
    end

    it "sanitizes content" do
      expect(StoryRepository.extract_content(entry)).to eq "Some test content"
    end

    it "falls back to summary if there is no content" do
      expect(StoryRepository.extract_content(summary_only)).to eq "Dumb publisher"
    end

    it "expands urls" do
      entry = double(url: "http://mdswanson.com",
                     content: nil,
                     summary: "<a href=\"page\">Page</a>")

      expect(StoryRepository.extract_content(entry)).to eq "<a href=\"http://mdswanson.com/page\">Page</a>"
    end

    it "ignores URL expansion if entry url is nil" do
      entry = double(url: nil,
                     content: nil,
                     summary: "<a href=\"page\">Page</a>")

      expect(StoryRepository.extract_content(entry)).to eq "<a href=\"page\">Page</a>"
    end
  end
end
