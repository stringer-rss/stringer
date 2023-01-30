# frozen_string_literal: true

require "spec_helper"

describe FeverAPI::ReadFeeds do
  subject { described_class.new(feed_repository:) }

  let(:feed_ids) { [5, 7, 11] }
  let(:feeds) do
    feed_ids.map { |id| double("feed", id:, as_fever_json: { id: }) }
  end
  let(:feed_repository) { double("repo") }

  it "returns a list of feeds" do
    expect(feed_repository).to receive(:list).and_return(feeds)
    expect(subject.call("feeds" => nil)).to eq(
      feeds: [
        { id: 5 },
        { id: 7 },
        { id: 11 }
      ]
    )
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
