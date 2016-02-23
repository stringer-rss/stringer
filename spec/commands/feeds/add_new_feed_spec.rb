require "spec_helper"

app_require "/commands/feeds/add_new_feed"

describe AddNewFeed do
  describe "#add" do
    context "feed cannot be discovered" do
      let(:discoverer) { double(discover: false) }
      it "returns false if cant discover any feeds" do
        result = AddNewFeed.add("http://not-a-feed.com", discoverer)

        expect(result).to eq(false)
      end
    end

    context "feed can be discovered" do
      let(:feed_url) { "http://feed.com/atom.xml" }
      let(:feed_result) { double(title: feed.name, feed_url: feed.url) }
      let(:discoverer) { double(discover: feed_result) }
      let(:feed) { FeedFactory.build }
      let(:repo) { double }

      it "parses and creates the feed if discovered" do
        expect(repo).to receive(:create).and_return(feed)

        result = AddNewFeed.add("http://feed.com", discoverer, repo)

        expect(result).to be feed
      end
    end
  end
end
