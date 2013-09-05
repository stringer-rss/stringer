require "spec_helper"

app_require "fever_api/read_feeds_groups"

describe FeverAPI::ReadFeedsGroups do
  let(:feed_ids) { [5, 7, 11] }
  let(:feeds) { feed_ids.map{|id| double('feed', id: id) } }
  let(:feed_repository) { double('repo') }

  subject do
    FeverAPI::ReadFeedsGroups.new(feed_repository: feed_repository)
  end

  it "returns a list of groups requested through feeds" do
    feed_repository.should_receive(:list).and_return(feeds)
    subject.call('feeds' => nil).should == {
      feeds_groups: [
        {
          group_id: 1,
          feed_ids: feed_ids.join(',')
        }
      ]
    }
  end

  it "returns a list of groups requested through groups" do
    feed_repository.should_receive(:list).and_return(feeds)
    subject.call('groups' => nil).should == {
      feeds_groups: [
        {
          group_id: 1,
          feed_ids: feed_ids.join(',')
        }
      ]
    }
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
