require "spec_helper"

app_require "commands/feeds/export_to_opml"

describe ExportToOpml do
  describe "#to_xml" do
    let(:feed_one) { FeedFactory.build }
    let(:feed_two) { FeedFactory.build }
    let(:feeds) { [feed_one, feed_two] }

    it "returns OPML XML" do
      result = ExportToOpml.new(feeds).to_xml

      outlines = Nokogiri.XML(result).xpath("//body//outline")
      expect(outlines.size).to eq(2)
      expect(outlines.first["title"]).to eq feed_one.name
      expect(outlines.first["xmlUrl"]).to eq feed_one.url
      expect(outlines.last["title"]).to eq feed_two.name
      expect(outlines.last["xmlUrl"]).to eq feed_two.url
    end

    it "handles empty feeds" do
      result = ExportToOpml.new([]).to_xml

      outlines = Nokogiri.XML(result).xpath("//body//outline")
      expect(outlines).to be_empty
    end

    it "has a proper title" do
      result = ExportToOpml.new(feeds).to_xml

      title = Nokogiri.XML(result).xpath("//head//title").first
      expect(title.content).to eq "Feeds from Stringer"
    end
  end
end
