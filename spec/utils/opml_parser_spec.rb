require "spec_helper"

app_require "utils/opml_parser"

describe OpmlParser do
  let(:parser) { OpmlParser.new }

  describe "#parse_feeds" do
    it "it returns a hash of feed details from an OPML file" do
      result = parser.parse_feeds(<<-eos)
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="1.0">
        <head>
          <title>matt swanson subscriptions in Google Reader</title>
        </head>
        <body>
          <outline text="a sample feed" title="a sample feed" type="rss"
              xmlUrl="http://feeds.feedburner.com/foobar" htmlUrl="http://www.example.org/"/>
          <outline text="lolol" title="Matt's Blog" type="rss"
              xmlUrl="http://mdswanson.com/atom.xml" htmlUrl="http://mdswanson.com/"/>
        </body>
        </opml>
      eos

      resulted_values = result.values.flatten
      expect(resulted_values.size).to eq 2
      expect(resulted_values.first[:name]).to eq "a sample feed"
      expect(resulted_values.first[:url]).to eq "http://feeds.feedburner.com/foobar"

      expect(resulted_values.last[:name]).to eq "Matt's Blog"
      expect(resulted_values.last[:url]).to eq "http://mdswanson.com/atom.xml"
      expect(result.keys.first).to eq "Ungrouped"
    end

    it "handles nested groups of feeds" do
      result = parser.parse_feeds(<<-eos)
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="1.0">
        <head>
          <title>matt swanson subscriptions in Google Reader</title>
        </head>
        <body>
          <outline text="Technology News">
            <outline text="a sample feed" title="a sample feed" type="rss"
                xmlUrl="http://feeds.feedburner.com/foobar" htmlUrl="http://www.example.org/"/>
          </outline>
        </body>
        </opml>
      eos
      resulted_values = result.values.flatten

      expect(resulted_values.count).to eq 1
      expect(resulted_values.first[:name]).to eq "a sample feed"
      expect(resulted_values.first[:url]).to eq "http://feeds.feedburner.com/foobar"
      expect(result.keys.first).to eq "Technology News"
    end

    it "doesn't explode when there are no feeds" do
      result = parser.parse_feeds(<<-eos)
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="1.0">
        <head>
          <title>matt swanson subscriptions in Google Reader</title>
        </head>
        <body>
        </body>
        </opml>
      eos

      expect(result).to be_empty
    end

    it "handles Feedly's exported OPML (missing :title)" do
      result = parser.parse_feeds(<<-eos)
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="1.0">
        <head>
          <title>My feeds (Feedly)</title>
        </head>
        <body>
          <outline text="a sample feed" type="rss"
              xmlUrl="http://feeds.feedburner.com/foobar" htmlUrl="http://www.example.org/"/>
        </body>
        </opml>
      eos
      resulted_values = result.values.flatten

      expect(resulted_values.count).to eq 1
      expect(resulted_values.first[:name]).to eq "a sample feed"
    end
  end
end
