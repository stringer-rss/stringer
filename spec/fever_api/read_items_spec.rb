require "spec_helper"

app_require "fever_api/read_items"

describe FeverAPI::ReadItems do
  let(:story_repository) { double('repo') }

  subject do
    FeverAPI::ReadItems.new(story_repository: story_repository)
  end

  it "returns a list of unread items including total count" do
    story_repository.should_receive(:unread).twice.and_return([
      double('story', as_fever_json: { id: 5 } ),
      double('story', as_fever_json: { id: 7 } ),
      double('story', as_fever_json: { id: 11 } )
    ])
    subject.call('items' => nil).should == {
      items: [
        { id: 5 },
        { id: 7 },
        { id: 11 }
      ],
      total_items: 3
    }
  end

  it "returns a list of unread items since id including total count" do
    story_repository.should_receive(:unread_since_id).with(3).and_return([
      double('story', as_fever_json: { id: 5 } ),
      double('story', as_fever_json: { id: 7 } ),
    ])
    story_repository.should_receive(:unread).and_return([
      double('story', as_fever_json: { id: 2 } ),
      double('story', as_fever_json: { id: 5 } ),
      double('story', as_fever_json: { id: 7 } ),
    ])
    subject.call('items' => nil, since_id: 3).should == {
      items: [
        { id: 5 },
        { id: 7 },
      ],
      total_items: 3
    }
  end

  it "returns a list of specified items including total count" do
    story_repository.should_receive(:fetch_by_ids).with(['5', '11']).twice.and_return([
      double('story', as_fever_json: { id: 5 } ),
      double('story', as_fever_json: { id: 11 } )
    ])
    subject.call('items' => nil, with_ids: '5,11').should == {
      items: [
        { id: 5 },
        { id: 11 }
      ],
      total_items: 2
    }
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
