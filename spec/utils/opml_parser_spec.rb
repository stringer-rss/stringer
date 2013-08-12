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

      result.count.should eq 2
      result.first[:name].should eq "a sample feed"
      result.first[:url].should eq "http://feeds.feedburner.com/foobar"
    
      result.last[:name].should eq "Matt's Blog"
      result.last[:url].should eq "http://mdswanson.com/atom.xml"
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

      result.count.should eq 1
      result.first[:name].should eq "a sample feed"
      result.first[:url].should eq "http://feeds.feedburner.com/foobar"
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

      result.should be_empty
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

      result.count.should eq 1
      result.first[:name].should eq "a sample feed"
    end
  end
end