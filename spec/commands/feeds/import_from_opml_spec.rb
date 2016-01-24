require "spec_helper"

app_require "commands/feeds/import_from_opml"

describe ImportFromOpml do
  let(:subscriptions) { File.open(File.expand_path("../../../support/files/subscriptions.xml", __FILE__)) }

  def import
    described_class.import(subscriptions)
  end

  after do
    Feed.delete_all
    Group.delete_all
  end

  let(:group_1) { Group.find_by_name("Football News") }
  let(:group_2) { Group.find_by_name("RoR") }

  context "adding group_id for existing feeds" do
    let!(:feed_1) do
      Feed.create(name: "TMW Football Transfer News", url: "http://www.transfermarketweb.com/rss")
    end
    let!(:feed_2) do
      Feed.create(
        name: "GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home",
        url: "http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots"
      )
    end
    before { import }

    it "retains exising feeds" do
      expect(feed_1).to be_valid
      expect(feed_2).to be_valid
    end

    it "creates new groups" do
      expect(group_1).to be
      expect(group_2).to be
    end

    it "sets group_id for existing feeds" do
      expect(feed_1.reload.group).to eq group_1
      expect(feed_2.reload.group).to eq group_2
    end
  end

  context "creates new feeds with groups" do
    let(:feed_1) do
      Feed.where(name: "TMW Football Transfer News", url: "http://www.transfermarketweb.com/rss")
    end
    let(:feed_2) do
      Feed.where(
        name: "GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home",
        url: "http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots"
      )
    end
    before { import }

    it "creates groups" do
      expect(group_1).to be
      expect(group_1).to be
    end

    it "creates feeds" do
      expect(feed_1).to exist
      expect(feed_2).to exist
    end

    it "sets group" do
      expect(feed_1.first.group).to eq group_1
      expect(feed_2.first.group).to eq group_2
    end
  end

  context "creates new feeds without group" do
    let(:feed_1) { Feed.where(name: "Autoblog", url: "http://feeds.autoblog.com/weblogsinc/autoblog/").first }
    let(:feed_2) { Feed.where(name: "City Guide News", url: "http://www.probki.net/news/RSS_news_feed.asp").first }

    before { import }

    it "does not create any new group for feeds without group" do
      expect(Group.where("id NOT IN (?)", [group_1.id, group_2.id]).count).to eq 0
    end

    it "creates feeds without group_id" do
      expect(feed_1.group_id).to be_nil
      expect(feed_2.group_id).to be_nil
    end
  end
end
