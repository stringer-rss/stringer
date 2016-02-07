require "spec_helper"

describe FetchFeeds do
  describe "#fetch_all" do
    let(:feeds) { [FeedFactory.build, FeedFactory.build] }
    let(:fetcher_one) { double }
    let(:fetcher_two) { double }
    let(:pool) { double }

    it "calls FetchFeed#fetch for every feed" do
      allow(pool).to receive(:process).and_yield
      allow(FetchFeed).to receive(:new).and_return(fetcher_one, fetcher_two)

      expect(fetcher_one).to receive(:fetch).once
      expect(fetcher_two).to receive(:fetch).once

      expect(pool).to receive(:shutdown)

      FetchFeeds.new(feeds, pool).fetch_all
    end
  end
end
