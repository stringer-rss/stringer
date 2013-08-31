require "spec_helper"

app_require "fever_api/sync_unread_item_ids"

describe FeverAPI::SyncUnreadItemIds do
  let(:story_ids) { [5, 7, 11] }
  let(:stories) { story_ids.map{|id| double('story', id: id) } }
  let(:story_repository) { double('repo') }

  subject do
    FeverAPI::SyncUnreadItemIds.new(story_repository: story_repository)
  end

  it "returns a list of unread items if requested" do
    story_repository.should_receive(:unread).and_return(stories)
    subject.call('unread_item_ids' => nil).should == { unread_item_ids: story_ids.join(',') }
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
