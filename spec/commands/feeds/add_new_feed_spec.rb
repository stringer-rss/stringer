require "spec_helper"

app_require "/commands/feeds/add_new_feed"

describe AddNewFeed do
  describe "#add" do
    context "feed cannot be discovered" do
      let(:discoverer) { stub(discover: false) }
      it "returns false if cant discover any feeds" do
        result = AddNewFeed.add("http://not-a-feed.com", discoverer)

        result.should be_false
      end
    end

    context "feed can be discovered" do
      let(:feed_url) { "http://feed.com/atom.xml" }
      let(:feed_result) { stub(title: feed.name, feed_url: feed.url) }
      let(:discoverer) { stub(discover: feed_result) }
      let(:feed) { FeedFactory.build }
      let(:repo) { stub }
      
      it "parses and creates the feed if discovered" do
        repo.should_receive(:create).and_return(feed)

        result = AddNewFeed.add("http://feed.com", discoverer, repo)

        result.should be feed
      end
    end
  end
end