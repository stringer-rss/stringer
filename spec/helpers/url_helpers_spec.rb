# frozen_string_literal: true

RSpec.describe UrlHelpers do
  def helper
    helper_class = Class.new { include UrlHelpers }
    helper_class.new
  end

  describe "#expand_absolute_urls" do
    it "preserves existing absolute urls" do
      content = '<a href="http://foo">bar</a>'

      expect(helper.expand_absolute_urls(content, nil)).to eq(content)
    end

    it "replaces relative urls in a, img and video tags" do
      content = <<~HTML
        <div>
        <img src="https://foo">
        <a href="/bar/baz">tee</a><img src="bar/bar">
        <video src="/tee"></video>
        </div>
      HTML

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      expect(result.delete("\n")).to eq(<<~HTML.delete("\n"))
        <div>
        <img src="https://foo">
        <a href="http://oodl.io/bar/baz">tee</a>
        <img src="http://oodl.io/d/bar/bar">
        <video src="http://oodl.io/tee"></video>
        </div>
      HTML
    end

    it "percent-encodes non-ascii characters in resolved relative urls" do
      content = '<a href="/why_no_了/">link</a>'

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      expect(result).to include('href="http://oodl.io/why_no_%E4%BA%86/"')
    end

    it "handles empty body" do
      expect(helper.expand_absolute_urls("", nil)).to eq("")
    end

    it "doesn't modify tags that do not have url attributes" do
      content = <<~HTML
        <div>
        <img foo="bar">
        <a name="something"></a>
        <video foo="bar"></video>
        </div>
      HTML

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      expect(result.delete("\n")).to eq(<<~HTML.delete("\n"))
        <div>
        <img foo="bar">
        <a name="something"></a>
        <video foo="bar"></video>
        </div>
      HTML
    end

    it "leaves the url as-is if it cannot be parsed" do
      weird_url =
        "https://github.com/aphyr/jepsen/blob/" \
        "1403f2d6e61c595bafede0d404fd4a893371c036/" \
        "elasticsearch/src/jepsen/system/elasticsearch.clj#" \
        "L161-L226.%20Then%20we'll%20write%20a%20%5Bregister%20test%5D(" \
        "https://github.com/aphyr/jepsen/blob/" \
        "1403f2d6e61c595bafede0d404fd4a893371c036/" \
        "elasticsearch/test/jepsen/system/elasticsearch_test.clj#L18-L50)"

      content = "<a href=\"#{weird_url}\"></a>"

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      expect(result).to include(weird_url)
    end
  end

  describe "#normalize_url" do
    it "resolves scheme-less urls" do
      ["http", "https"].each do |scheme|
        feed_url = "#{scheme}://blog.golang.org/feed.atom"

        url = helper.normalize_url("//blog.golang.org/context", feed_url)

        expect(url).to eq("#{scheme}://blog.golang.org/context")
      end
    end

    it "leaves urls with a scheme intact" do
      input = "http://blog.golang.org/context"
      normalized_url = helper.normalize_url(
        input, "http://blog.golang.org/feed.atom"
      )
      expect(normalized_url).to eq(input)
    end

    it "falls back to http if the base_url is also sheme less" do
      url = helper.normalize_url(
        "//blog.golang.org/context", "//blog.golang.org/feed.atom"
      )
      expect(url).to eq("http://blog.golang.org/context")
    end

    it "resolves relative urls" do
      url = helper.normalize_url(
        "/progrium/dokku/releases/tag/v0.4.4",
        "https://github.com/progrium/dokku/releases.atom"
      )
      expect(url).to eq("https://github.com/progrium/dokku/releases/tag/v0.4.4")
    end

    it "percent-encodes non-ascii (IRI) paths" do
      url = helper.normalize_url(
        "https://www.reddit.com/r/ChineseLanguage/comments/1u04wzs/" \
        "why_no_了_in_the_3rd_one/",
        "https://www.reddit.com/feed.xml"
      )
      expect(url).to eq(
        "https://www.reddit.com/r/ChineseLanguage/comments/1u04wzs/" \
        "why_no_%E4%BA%86_in_the_3rd_one/"
      )
    end

    it "leaves already-encoded urls intact (no double-encoding)" do
      input =
        "https://www.reddit.com/r/ChineseLanguage/comments/1u04wzs/" \
        "why_no_%E4%BA%86_in_the_3rd_one/"
      url = helper.normalize_url(input, "https://www.reddit.com/feed.xml")
      expect(url).to eq(input)
    end

    it "returns nil for javascript: scheme" do
      url = helper.normalize_url(
        "javascript:alert(1)", "https://example.com/feed.xml"
      )
      expect(url).to be_nil
    end

    it "returns nil for data: scheme" do
      url = helper.normalize_url(
        "data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==",
        "https://example.com/feed.xml"
      )
      expect(url).to be_nil
    end

    it "returns nil for other non-http schemes" do
      ["vbscript:msgbox(1)", "file:///etc/passwd"].each do |bad|
        expect(
          helper.normalize_url(bad, "https://example.com/feed.xml")
        ).to be_nil
      end
    end

    it "rejects case-mangled javascript: scheme" do
      url = helper.normalize_url(
        "JaVaScRiPt:alert(1)", "https://example.com/feed.xml"
      )
      expect(url).to be_nil
    end
  end
end
