require "spec_helper"

app_require "commands/stories/import_from_google_reader_stars"

describe ImportFromGoogleReaderStars do
  describe "#import" do
    let(:starred_text) { IO.read("spec/sample_data/starred.json") }

    before do
      Feed.create(name: "Ars Technica",
                  url: "http://feeds.arstechnica.com/arstechnica/everything",
                  last_fetched: 0)
    end

    it "imports starred items" do
      ImportFromGoogleReaderStars.import(starred_text)

      StoryRepository.starred.count.should eq 2
      
      story1 = Story.where(title: "Thanks to modders, gamers can play Super Mareo Bruhs inside Counter-Strike: GO")
      story1.count.should eq 1
      story1.first.body.should include "SourceMod Entertainment System"
      story1.first.is_starred.should eq true

      story2 = Story.where(title: "Economists demonstrate exactly why bank robbery is a bad idea")
      story2.count.should eq 1
      story2.first.body.should include "We can tell you exactly why robbing banks is a bad idea"
      story2.first.is_starred.should eq true
    end
  end
end