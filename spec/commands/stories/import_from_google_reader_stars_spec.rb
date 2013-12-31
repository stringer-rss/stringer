require "spec_helper"

app_require "commands/stories/import_from_google_reader_stars"

describe ImportFromGoogleReaderStars do
  describe "#import" do
    let(:starred_text) { IO.read("spec/sample_data/starred.json") }
    let(:story1_title) { "Thanks to modders, gamers can play Super Mareo Bruhs inside Counter-Strike: GO" }
    let(:story1_excerpt) { "SourceMod Entertainment System" }
    let(:story2_title) { "Economists demonstrate exactly why bank robbery is a bad idea" }
    let(:story2_excerpt) { "We can tell you exactly why robbing banks is a bad idea" }
    let(:feed_name) { "Ars Technica" }
    let(:feed_url) { "http://feeds.arstechnica.com/arstechnica/everything" }

    def create_feed_and_import_stars
      Feed.create(name: feed_name,
                  url: feed_url,
                  last_fetched: 0)

      ImportFromGoogleReaderStars.import(starred_text)
    end

    def destroy_feed
      Feed.where(name: feed_name).first.destroy
    end

    it "imports starred items" do
      create_feed_and_import_stars

      StoryRepository.all_starred.count.should eq 2

      story1 = Story.where(title: story1_title)
      story1.count.should eq 1
      story1.first.body.should include story1_excerpt
      story1.first.is_starred.should eq true

      story2 = Story.where(title: story2_title)
      story2.count.should eq 1
      story2.first.body.should include story2_excerpt
      story2.first.is_starred.should eq true

      destroy_feed
    end

    it "stars unstarred items" do
      create_feed_and_import_stars

      story1 = Story.where(title: story1_title)
      story1.first.is_starred = false
      story1.first.entry_id = "the importer should rely on my permalink not my entry_id to decide i should be starred"
      StoryRepository.save(story1.first)

      StoryRepository.all_starred.count.should eq 1

      ImportFromGoogleReaderStars.import(starred_text)

      StoryRepository.all_starred.count.should eq 2

      story1 = Story.where(title: story1_title)
      story1.first.is_starred.should eq true

      destroy_feed
    end

    it "skips unsubscribed feeds" do
      create_feed_and_import_stars
      destroy_feed

      skipped_feeds = ImportFromGoogleReaderStars.import(starred_text)

      skipped_feeds.count.should eq 1
      skipped_feeds[0].should eq feed_url
    end
  end
end