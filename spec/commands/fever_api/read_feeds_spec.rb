# frozen_string_literal: true

describe FeverAPI::ReadFeeds do
  it "returns a list of feeds" do
    feeds = create_list(:feed, 3)
    expect(described_class.call("feeds" => nil)).to eq(
      feeds: feeds.map(&:as_fever_json)
    )
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
