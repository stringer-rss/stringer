require "spec_helper"

app_require "fever_api/sync_saved_item_ids"

describe FeverAPI::SyncSavedItemIds do
  let(:story_ids) { [5, 7, 11] }
  let(:stories) { story_ids.map { |id| double("story", id: id) } }
  let(:story_repository) { double("repo") }

  subject do
    FeverAPI::SyncSavedItemIds.new(story_repository: story_repository)
  end

  it "returns a list of starred items if requested" do
    expect(story_repository).to receive(:all_starred).and_return(stories)
    expect(subject.call("saved_item_ids" => nil)).to eq(saved_item_ids: story_ids.join(","))
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
