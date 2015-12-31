require "spec_helper"

app_require "helpers/url_helpers"

RSpec.describe UrlHelpers do
  class Helper
    include UrlHelpers
  end

  let(:helper) { Helper.new }

  describe "#expand_absolute_urls" do
    it "preserves existing absolute urls" do
      content = '<a href="http://foo">bar</a>'

      helper.expand_absolute_urls(content, nil).should eq content
    end

    it "replaces relative urls in a, img and video tags" do
      content = <<-EOS
<div>
<img src="https://foo">
<a href="/bar/baz">tee</a><img src="bar/bar">
<video src="/tee"></video>
</div>
      EOS

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      result.gsub(/\n/, "").should eq <<-EOS.gsub(/\n/, "")
<div>
<img src="https://foo">
<a href="http://oodl.io/bar/baz">tee</a>
<img src="http://oodl.io/d/bar/bar">
<video src="http://oodl.io/tee"></video>
</div>
      EOS
    end

    it "handles empty body" do
      helper.expand_absolute_urls("", nil).should eq ""
    end

    it "doesn't modify tags that do not have url attributes" do
      content = <<-EOS
<div>
<img foo="bar">
<a name="something"/></a>
<video foo="bar"></video>
</div>
      EOS

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      result.gsub(/\n/, "").should eq <<-EOS.gsub(/\n/, "")
<div>
<img foo="bar">
<a name="something"></a>
<video foo="bar"></video>
</div>
      EOS
    end

    it "leaves the url as-is if it cannot be parsed" do
      weird_url = "https://github.com/aphyr/jepsen/blob/" \
        "1403f2d6e61c595bafede0d404fd4a893371c036/" \
        "elasticsearch/src/jepsen/system/elasticsearch.clj#" \
        "L161-L226.%20Then%20we'll%20write%20a%20%5Bregister%20test%5D(" \
        "https://github.com/aphyr/jepsen/blob/" \
        "1403f2d6e61c595bafede0d404fd4a893371c036/" \
        "elasticsearch/test/jepsen/system/elasticsearch_test.clj#L18-L50)"

      content = "<a href=\"#{weird_url}\"></a>"

      result = helper.expand_absolute_urls(content, "http://oodl.io/d/")
      result.should include(weird_url)
    end
  end

  describe "#normalize_url" do
    it "resolves scheme-less urls" do
      %w(http https).each do |scheme|
        feed_url = "#{scheme}://blog.golang.org/feed.atom"

        url = helper.normalize_url("//blog.golang.org/context", feed_url)

        url.should eq "#{scheme}://blog.golang.org/context"
      end
    end

    it "leaves urls with a scheme intact" do
      input = 'http://blog.golang.org/context'
      normalized_url = helper.normalize_url(
        input, 'http://blog.golang.org/feed.atom'
      )
      normalized_url.should eq(input)
    end

    it "falls back to http if the base_url is also sheme less" do
      url = helper.normalize_url(
        "//blog.golang.org/context", "//blog.golang.org/feed.atom"
      )
      url.should eq 'http://blog.golang.org/context'
    end

    it "resolves relative urls" do
      url = helper.normalize_url(
        "/progrium/dokku/releases/tag/v0.4.4",
        "https://github.com/progrium/dokku/releases.atom"
      )
      url.should eq "https://github.com/progrium/dokku/releases/tag/v0.4.4"
    end
  end
end
