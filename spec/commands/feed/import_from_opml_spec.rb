# frozen_string_literal: true

RSpec.describe Feed::ImportFromOpml do
  tmw_football = {
    name: "TMW Football Transfer News",
    url: "http://www.transfermarketweb.com/rss"
  }

  giant_robots = {
    name: "GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home",
    url: "http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots"
  }

  autoblog = { name: "Autoblog", url: "http://feeds.autoblog.com/weblogsinc/autoblog/" }
  city_guide = { name: "City Guide News", url: "http://www.probki.net/news/RSS_news_feed.asp" }
  macrumors = { name: "MacRumors: Mac News and Rumors - Front Page", url: "http://feeds.macrumors.com/MacRumors-Front" }
  dead_feed = { name: "http://deadfeed.example.com/feed.rss", url: "http://deadfeed.example.com/feed.rss" }

  def read_subscriptions
    File.open(
      File.expand_path("../../support/files/subscriptions.xml", __dir__)
    )
  end

  def create_feed(feed_details)
    create(:feed, feed_details)
  end

  def find_feed(feed_details)
    Feed.where(feed_details)
  end

  before do
    stub_request(:get, "http://feeds.macrumors.com/MacRumors-Front").to_return(
      status: 200,
      body: File.read("spec/sample_data/feeds/feed01_valid_feed/feed.xml")
    )
    stub_request(
      :get,
      "http://deadfeed.example.com/feed.rss"
    ).to_return(status: 404)
  end

  context "adds title for existing feed" do
    it "changes existing feed if name is nil" do
      create_feed({ name: nil, url: macrumors[:url] })

      described_class.call(read_subscriptions, user: default_user)

      expect(find_feed(macrumors)).to exist
    end

    it "keeps existing feed name if name is something else" do
      feed1 = create_feed({ name: "MacRumors", url: macrumors[:url] })

      described_class.call(read_subscriptions, user: default_user)

      expect(find_feed(macrumors)).not_to exist
      feed1.reload
      expect(feed1.name).to eq("MacRumors")
    end
  end

  context "adding group_id for existing feeds" do
    it "retains exising feeds" do
      feed1 = create_feed(tmw_football)
      feed2 = create_feed(giant_robots)

      described_class.call(read_subscriptions, user: default_user)

      expect(feed1).to be_valid
      expect(feed2).to be_valid
    end

    it "creates new groups" do
      described_class.call(read_subscriptions, user: default_user)

      expect(Group.find_by(name: "Football News")).to be
      expect(Group.find_by(name: "RoR")).to be
    end

    it "sets group for existing feeds" do
      feed1 = create_feed(tmw_football)
      feed2 = create_feed(giant_robots)

      expect { described_class.call(read_subscriptions, user: default_user) }
        .to change_record(feed1, :group_name).from(nil).to("Football News")
        .and change_record(feed2, :group_name).from(nil).to("RoR")
    end
  end

  context "creates new feeds with groups" do
    it "creates groups" do
      described_class.call(read_subscriptions, user: default_user)

      expect(Group.find_by(name: "Football News")).to be
      expect(Group.find_by(name: "RoR")).to be
    end

    it "creates feeds" do
      described_class.call(read_subscriptions, user: default_user)

      expect(find_feed(tmw_football)).to exist
      expect(find_feed(giant_robots)).to exist
      expect(find_feed(macrumors)).to exist
      expect(find_feed(dead_feed)).to exist
    end

    it "sets group" do
      described_class.call(read_subscriptions, user: default_user)

      expect(find_feed(tmw_football).first.group)
        .to eq(Group.find_by(name: "Football News"))
      expect(find_feed(giant_robots).first.group)
        .to eq(Group.find_by(name: "RoR"))
    end

    it "does not create empty group" do
      described_class.call(read_subscriptions, user: default_user)

      expect(Group.find_by(name: "Empty Group")).to be_nil
    end
  end

  context "creates new feeds without group" do
    it "does not create any new group for feeds without group" do
      described_class.call(read_subscriptions, user: default_user)

      group1 = Group.find_by(name: "Football News")
      group2 = Group.find_by(name: "RoR")

      expect(Group.where.not(id: [group1.id, group2.id]).count).to eq(0)
    end

    it "creates feeds without group_id" do
      described_class.call(read_subscriptions, user: default_user)

      expect(find_feed(autoblog).first.group_id).to be_nil
      expect(find_feed(city_guide).first.group_id).to be_nil
    end
  end
end
