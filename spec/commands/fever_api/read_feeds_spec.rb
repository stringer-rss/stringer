# frozen_string_literal: true

RSpec.describe FeverAPI::ReadFeeds do
  it "returns a list of feeds" do
    feeds = create_list(:feed, 3)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, feeds: nil))
      .to eq(feeds: feeds.map(&:as_fever_json))
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
