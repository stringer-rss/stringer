# frozen_string_literal: true

require "spec_helper"

describe FeverAPI::SyncSavedItemIds do
  subject { described_class.new(story_repository:) }

  let(:story_ids) { [5, 7, 11] }
  let(:stories) { story_ids.map { |id| double("story", id:) } }
  let(:story_repository) { double("repo") }

  it "returns a list of starred items if requested" do
    expect(story_repository).to receive(:all_starred).and_return(stories)
    expect(subject.call("saved_item_ids" => nil))
      .to eq(saved_item_ids: story_ids.join(","))
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
