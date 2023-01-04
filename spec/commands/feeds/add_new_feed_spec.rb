# frozen_string_literal: true

require "spec_helper"

app_require "/commands/feeds/add_new_feed"

describe AddNewFeed do
  describe "#add" do
    context "feed cannot be discovered" do
      let(:discoverer) { double(discover: false) }

      it "returns false if cant discover any feeds" do
        result = described_class.add("http://not-a-feed.com", discoverer)

        expect(result).to be(false)
      end
    end

    context "feed can be discovered" do
      let(:feed_url) { "http://feed.com/atom.xml" }
      let(:feed_result) { double(title: feed.name, feed_url: feed.url) }
      let(:discoverer) { double(discover: feed_result) }
      let(:feed) { build(:feed) }
      let(:repo) { double }

      it "parses and creates the feed if discovered" do
        expect(repo).to receive(:create).and_return(feed)

        result = described_class.add("http://feed.com", discoverer, repo)

        expect(result).to be feed
      end

      context "title includes a script tag" do
        let(:feed_result) do
          double(
            title: "foo<script>alert('xss');</script>bar",
            feed_url: feed.url
          )
        end

        it "deletes the script tag from the title" do
          allow(repo).to receive(:create)

          described_class.add("http://feed.com", discoverer, repo)

          expect(repo).to have_received(:create).with(include(name: "foobar"))
        end
      end
    end

    it "uses feed_url as name when title is not present" do
      feed_url = "https://protomen.com/news/feed"
      result = instance_double(Feedjira::Parser::RSS, title: nil, feed_url:)
      discoverer = instance_double(FeedDiscovery, discover: result)

      expect { described_class.add(feed_url, discoverer) }
        .to change(Feed, :count).by(1)

      expect(Feed.last.name).to eq(feed_url)
    end
  end
end
