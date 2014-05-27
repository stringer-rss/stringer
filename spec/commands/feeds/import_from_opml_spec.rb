require 'spec_helper'

app_require "commands/feeds/import_from_opml"

describe ImportFromOpml do
  let(:subscriptions) { File.open(File.expand_path('../../../support/files/subscriptions.xml', __FILE__)) }

  def import
    described_class.import(subscriptions)
  end

  after do
    Feed.delete_all
    Group.delete_all
  end

  let(:group_1 ) { Group.find_by_name('Football News') }
  let(:group_2 ) { Group.find_by_name('RoR') }

  context 'adding group_id for existing feeds' do
    let!(:feed_1) { Feed.create(name: 'TMW Football Transfer News',
                                url: 'http://www.transfermarketweb.com/rss') }
    let!(:feed_2) { Feed.create(name: 'GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home',
                                url: 'http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots') }
    before { import }

    it 'retains exising feeds' do
      feed_1.should be_valid
      feed_2.should be_valid
    end

    it 'creates new groups' do
      group_1.should be
      group_2.should be
    end

    it 'sets group_id for existing feeds' do
      feed_1.reload.group.should eq group_1
      feed_2.reload.group.should eq group_2
    end
  end

  context 'creates new feeds with groups' do
    let(:feed_1) { Feed.where(name: 'TMW Football Transfer News',
                              url: 'http://www.transfermarketweb.com/rss') }

    let(:feed_2) { Feed.where(name: 'GIANT ROBOTS SMASHING INTO OTHER GIANT ROBOTS - Home',
                              url: 'http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots') }
    before { import }

    it 'creates groups' do
      group_1.should be
      group_1.should be
    end

    it 'creates feeds' do
      feed_1.should exist
      feed_2.should exist
    end

    it 'sets group' do
      feed_1.first.group.should eq group_1
      feed_2.first.group.should eq group_2
    end
  end

  context 'creates new feeds without group' do
    let(:feed_1) { Feed.where(name: 'Autoblog', url: 'http://feeds.autoblog.com/weblogsinc/autoblog/').first }
    let(:feed_2) { Feed.where(name: 'City Guide News', url: 'http://www.probki.net/news/RSS_news_feed.asp').first }

    before { import }

    it 'does not create any new group for feeds without group' do
      Group.where('id NOT IN (?)', [group_1.id, group_2.id]).count.should eq 0
    end

    it 'creates feeds without group_id' do
      feed_1.group_id.should be_nil
      feed_2.group_id.should be_nil
    end
  end
end
