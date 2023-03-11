# frozen_string_literal: true

RSpec.describe Feed::ImportFromOpml do
  let(:subscriptions) do
    File.open(
      File.expand_path(
        "../../support/files/subscriptions.xml",
        __dir__
      )
    )
  end
  let(:group1) { Group.find_by!(name: "Football News") }
  let(:group2) { Group.find_by!(name: "RoR")           }

  context "adding group_id for existing feeds" do
    let!(:feed1) do
      create(:feed, name: "TMW Football Transfer News", url: "http://www.transfermarketweb.com/rss")
    end
    let!(:feed2) do
      create(
        :feed,
        name: "GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home",
        url: "http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots"
      )
    end

    it "retains exising feeds" do
      described_class.call(subscriptions, user: default_user)

      expect(feed1).to be_valid
      expect(feed2).to be_valid
    end

    it "creates new groups" do
      described_class.call(subscriptions, user: default_user)

      expect(group1).to be
      expect(group2).to be
    end

    it "sets group for existing feeds" do
      expect { described_class.call(subscriptions, user: default_user) }
        .to change_record(feed1, :group_name).from(nil).to("Football News")
        .and change_record(feed2, :group_name).from(nil).to("RoR")
    end
  end

  context "creates new feeds with groups" do
    let(:feed1) do
      Feed.where(name: "TMW Football Transfer News", url: "http://www.transfermarketweb.com/rss")
    end
    let(:feed2) do
      Feed.where(
        name: "GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home",
        url: "http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots"
      )
    end

    it "creates groups" do
      described_class.call(subscriptions, user: default_user)

      expect(group1).to be
      expect(group1).to be
    end

    it "creates feeds" do
      described_class.call(subscriptions, user: default_user)

      expect(feed1).to exist
      expect(feed2).to exist
    end

    it "sets group" do
      described_class.call(subscriptions, user: default_user)

      expect(feed1.first.group).to eq(group1)
      expect(feed2.first.group).to eq(group2)
    end

    it "does not create empty group" do
      described_class.call(subscriptions, user: default_user)

      expect(Group.find_by(name: "Empty Group")).to be_nil
    end
  end

  context "creates new feeds without group" do
    let(:feed1) { Feed.where(name: "Autoblog", url: "http://feeds.autoblog.com/weblogsinc/autoblog/").first }
    let(:feed2) { Feed.where(name: "City Guide News", url: "http://www.probki.net/news/RSS_news_feed.asp").first }

    it "does not create any new group for feeds without group" do
      described_class.call(subscriptions, user: default_user)

      expect(Group.where.not(id: [group1.id, group2.id]).count).to eq(0)
    end

    it "creates feeds without group_id" do
      described_class.call(subscriptions, user: default_user)

      expect(feed1.group_id).to be_nil
      expect(feed2.group_id).to be_nil
    end
  end
end
