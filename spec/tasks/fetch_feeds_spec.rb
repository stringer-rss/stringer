require "spec_helper"

describe FetchFeeds do
  describe "#fetch_all" do
    let(:feeds) { [FeedFactory.build, FeedFactory.build] }
    let(:fetcher_one) { double }
    let(:fetcher_two) { double }
    let(:pool) { double }

    it "calls FetchFeed#fetch for every feed" do
      pool.stub(:process).and_yield
      FetchFeed.stub(:new).and_return(fetcher_one, fetcher_two)

      fetcher_one.should_receive(:fetch).once
      fetcher_two.should_receive(:fetch).once

      pool.should_receive(:shutdown)

      FetchFeeds.new(feeds, pool).fetch_all
    end
  end
end
