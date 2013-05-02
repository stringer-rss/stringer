require "spec_helper"

app_require "commands/feeds/export_to_opml"

describe ExportToOpml do
  describe "#to_xml" do
    let(:feed_one) { FeedFactory.build }
    let(:feed_two) { FeedFactory.build }
    let(:feeds) { [feed_one, feed_two]}

    it "returns OPML XML" do
      result = ExportToOpml.new(feeds).to_xml

      outlines = Nokogiri.XML(result).xpath("//body//outline")
      outlines.should have(2).items
      outlines.first["title"].should eq feed_one.name
      outlines.first["xmlUrl"].should eq feed_one.url
      outlines.last["title"].should eq feed_two.name
      outlines.last["xmlUrl"].should eq feed_two.url
    end

    it "handles empty feeds" do
      result = ExportToOpml.new([]).to_xml

      outlines = Nokogiri.XML(result).xpath("//body//outline")
      outlines.should have(0).items
    end

    it "has a proper title" do
      result = ExportToOpml.new(feeds).to_xml

      title = Nokogiri.XML(result).xpath("//head//title").first
      title.content.should eq "Feeds from Stringer"
    end
  end
end