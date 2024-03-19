# frozen_string_literal: true

RSpec.describe RemoveOldStories do
  def create_stories
    stories = double("stories")
    allow(stories).to receive(:delete_all)
    stories
  end

  it "passes along the number of days to the story repository query" do
    allow(described_class).to receive(:pruned_feeds).and_return([])

    expect(StoryRepository).to receive(:unstarred_read_stories_older_than)
      .with(7).and_return(create_stories)

    described_class.call(7)
  end

  it "requests deletion of all old stories" do
    allow(described_class).to receive(:pruned_feeds).and_return([])
    mocked_stories = create_stories
    allow(StoryRepository)
      .to receive(:unstarred_read_stories_older_than) { mocked_stories }

    expect(mocked_stories).to receive(:delete_all)

    described_class.call(11)
  end

  it "fetches affected feeds by id" do
    stories = create_list(:story, 3, :read, created_at: 1.month.ago)

    described_class.call(13)

    expect(Story.where(id: stories.map(&:id))).to be_empty
  end

  it "updates last_fetched on affected feeds" do
    feeds = [double("feed a"), double("feed b")]
    allow(described_class).to receive(:pruned_feeds) { feeds }
    allow(described_class).to receive(:old_stories) { create_stories }

    expect(FeedRepository)
      .to receive(:update_last_fetched).with(feeds.first, anything)
    expect(FeedRepository)
      .to receive(:update_last_fetched).with(feeds.last, anything)

    described_class.call(13)
  end
end
