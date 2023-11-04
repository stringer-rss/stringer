# frozen_string_literal: true

RSpec.describe Feed::ExportToOpml do
  it "returns OPML XML" do
    feed_one, feed_two = build_pair(:feed)
    result = described_class.call([feed_one, feed_two])

    outlines = Nokogiri.XML(result).xpath("//body//outline")
    expect(outlines.size).to eq(2)
    expect(outlines.first["title"]).to eq(feed_one.name)
    expect(outlines.first["xmlUrl"]).to eq(feed_one.url)
    expect(outlines.last["title"]).to eq(feed_two.name)
    expect(outlines.last["xmlUrl"]).to eq(feed_two.url)
  end

  it "handles empty feeds" do
    result = described_class.call([])

    outlines = Nokogiri.XML(result).xpath("//body//outline")
    expect(outlines).to be_empty
  end

  it "has a proper title" do
    feed_one, feed_two = build_pair(:feed)
    result = described_class.call([feed_one, feed_two])

    title = Nokogiri.XML(result).xpath("//head//title").first
    expect(title.content).to eq("Feeds from Stringer")
  end
end
