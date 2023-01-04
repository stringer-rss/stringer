# frozen_string_literal: true

require "spec_helper"
app_require "tasks/remove_old_stories"

describe RemoveOldStories do
  describe ".remove!" do
    let(:stories_mock) do
      stories = double("stories")
      allow(stories).to receive(:delete_all)
      stories
    end

    it "passes along the number of days to the story repository query" do
      allow(described_class).to receive(:pruned_feeds).and_return([])

      expect(StoryRepository).to receive(:unstarred_read_stories_older_than)
        .with(7).and_return(stories_mock)

      described_class.remove!(7)
    end

    it "requests deletion of all old stories" do
      allow(described_class).to receive(:pruned_feeds).and_return([])
      allow(StoryRepository)
        .to receive(:unstarred_read_stories_older_than) { stories_mock }

      expect(stories_mock).to receive(:delete_all)

      described_class.remove!(11)
    end

    it "fetches affected feeds by id" do
      allow(described_class).to receive(:old_stories) do
        stories = [double("story", feed_id: 3), double("story", feed_id: 5)]
        allow(stories).to receive(:delete_all)
        stories
      end

      expect(FeedRepository)
        .to receive(:fetch_by_ids).with([3, 5]).and_return([])

      described_class.remove!(13)
    end

    it "updates last_fetched on affected feeds" do
      feeds = [double("feed a"), double("feed b")]
      allow(described_class).to receive(:pruned_feeds) { feeds }
      allow(described_class).to receive(:old_stories) { stories_mock }

      expect(FeedRepository)
        .to receive(:update_last_fetched).with(feeds.first, anything)
      expect(FeedRepository)
        .to receive(:update_last_fetched).with(feeds.last, anything)

      described_class.remove!(13)
    end
  end
end
