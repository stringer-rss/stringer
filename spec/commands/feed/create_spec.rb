# frozen_string_literal: true

RSpec.describe Feed::Create do
  context "feed cannot be discovered" do
    it "returns false if cant discover any feeds" do
      expect(FeedDiscovery).to receive(:call).and_return(false)
      result = described_class.call("http://not-a-feed.com", user: default_user)

      expect(result).to be(false)
    end
  end

  context "feed can be discovered" do
    let(:feed_url) { "http://feed.com/atom.xml" }
    let(:feed_result) { double(title: feed.name, feed_url: feed.url) }
    let(:feed) { build(:feed) }

    it "parses and creates the feed if discovered" do
      expect(FeedDiscovery).to receive(:call).and_return(feed_result)

      expect { described_class.call("http://feed.com", user: default_user) }
        .to change(Feed, :count).by(1)
    end

    context "title includes a script tag" do
      let(:feed_result) do
        double(
          title: "foo<script>alert('xss');</script>bar",
          feed_url: feed.url
        )
      end

      it "deletes the script tag from the title" do
        expect(FeedDiscovery).to receive(:call).and_return(feed_result)

        feed = described_class.call("http://feed.com", user: default_user)

        expect(feed.name).to eq("foobar")
      end
    end
  end

  it "uses feed_url as name when title is not present" do
    feed_url = "https://protomen.com/news/feed"
    result = instance_double(Feedjira::Parser::RSS, title: nil, feed_url:)
    expect(FeedDiscovery).to receive(:call).and_return(result)

    expect { described_class.call(feed_url, user: default_user) }
      .to change(Feed, :count).by(1)

    expect(Feed.last.name).to eq(feed_url)
  end
end
