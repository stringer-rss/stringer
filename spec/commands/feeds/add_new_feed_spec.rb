require "spec_helper"

app_require "/commands/feeds/add_new_feed"

describe AddNewFeed do
  describe "#add" do
    context "feed cannot be discovered" do
      let(:finder) { stub(find: []) }
      it "returns false if cant discover any feeds" do
        result = AddNewFeed.add("http://not-a-feed.com", finder)

        result.should be_false
      end
    end

    context "feed can be discovered" do
      let(:feed_url) { "http://feed.com/atom.xml" }
      let(:feed_result) { stub(title: feed.name, feed_url: feed.url) }
      let(:feed) { FeedFactory.build }
      let(:finder) { stub(find: [feed_url]) }
      let(:repo) { stub }
      let(:parser) { stub(fetch_and_parse: feed_result) }
      
      it "parses and creates the feed if discovered" do
        repo.should_receive(:create).and_return(feed)

        result = AddNewFeed.add("http://feed.com", finder, parser, repo)

        result.should be feed
      end
    end
  end
end