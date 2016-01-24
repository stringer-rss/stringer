require "spec_helper"

app_require "fever_api/read_feeds"

describe FeverAPI::ReadFeeds do
  let(:feed_ids) { [5, 7, 11] }
  let(:feeds) { feed_ids.map { |id| double("feed", id: id, as_fever_json: { id: id }) } }
  let(:feed_repository) { double("repo") }

  subject do
    FeverAPI::ReadFeeds.new(feed_repository: feed_repository)
  end

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
