require "spec_helper"

app_require "repositories/story_repository"

describe StoryRepository do
  describe '.add' do
    let(:feed) { double(url: 'http://blog.golang.org/feed.atom') }
    before do
      Story.stub(:create)
    end

    it 'normalizes story urls' do
      entry = double(url: '//blog.golang.org/context', title: '', content: '').as_null_object
      StoryRepository.should receive(:normalize_url).with(entry.url, feed.url)

      StoryRepository.add(entry, feed)
    end

    it "sanitizes titles" do
      entry = double(title: "n\u2028\u2029", content: '').as_null_object
      StoryRepository.stub(:normalize_url)

      Story.should receive(:create).with(hash_including(title: "n"))

      StoryRepository.add(entry, feed)
    end
  end

  describe ".expand_absolute_urls" do
    it "preserves existing absolute urls" do
      content = '<a href="http://foo">bar</a>'

      StoryRepository.expand_absolute_urls(content, nil).should eq content
    end

    it "replaces relative urls in a, img and video tags" do
      content = <<-EOS
<div>
<img src="https://foo">
<a href="/bar/baz">tee</a><img src="bar/bar">
<video src="/tee"></video>
</div>
      EOS

      result = StoryRepository.expand_absolute_urls(content, "http://oodl.io/d/")
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
      StoryRepository.expand_absolute_urls("", nil).should eq ""
    end

    it "doesn't modify tags that do not have url attributes" do
      content = <<-EOS
<div>
<img foo="bar">
<a name="something"/></a>
<video foo="bar"></video>
</div>
      EOS

      result = StoryRepository.expand_absolute_urls(content, "http://oodl.io/d/")
      result.gsub(/\n/, "").should eq <<-EOS.gsub(/\n/, "")
<div>
<img foo="bar">
<a name="something"></a>
<video foo="bar"></video>
</div>
      EOS
    end

    it "leaves the url as-is if it cannot be parsed" do
      weird_url = "https://github.com/aphyr/jepsen/blob/1403f2d6e61c595bafede0d404fd4a893371c036/elasticsearch/src/jepsen/system/elasticsearch.clj#L161-L226.%20Then%20we'll%20write%20a%20%5Bregister%20test%5D(https://github.com/aphyr/jepsen/blob/1403f2d6e61c595bafede0d404fd4a893371c036/elasticsearch/test/jepsen/system/elasticsearch_test.clj#L18-L50)"

      content = <<-EOS
      <a href="#{weird_url}"></a>
      EOS

      result = StoryRepository.expand_absolute_urls(content, "http://oodl.io/d/")
      result.should include(weird_url)
    end
  end

  describe ".extract_content" do
    let(:entry) do
      double(url: "http://mdswanson.com",
           content: "Some test content<script></script>")
    end

    let(:summary_only) do
      double(url: "http://mdswanson.com",
           content: nil,
           summary: "Dumb publisher")
    end

    it "sanitizes content" do
      StoryRepository.extract_content(entry).should eq "Some test content"
    end

    it "falls back to summary if there is no content" do
      StoryRepository.extract_content(summary_only).should eq "Dumb publisher"
    end
  end

  describe ".sanitize" do
    context "regressions" do
      it "handles <wbr> tag properly" do
        result = StoryRepository.sanitize("<code>WM_<wbr\t\n >ERROR</code> asdf")
        result.should eq "<code>WM_ERROR</code> asdf"
      end

      it "handles <figure> tag properly" do
        result = StoryRepository.sanitize("<figure>some code</figure>")
        result.should eq "<figure>some code</figure>"
      end

      it "handles unprintable characters" do
        result = StoryRepository.sanitize("n\u2028\u2029")
        result.should eq "n"
      end

      it "preserves line endings" do
        result = StoryRepository.sanitize("test\r\ncase")
        result.should eq "test\r\ncase"
      end
    end
  end

  describe ".normalize_url" do
    it "resolves scheme-less urls" do
      %w{http https}.each do |scheme|
        feed_url = "#{scheme}://blog.golang.org/feed.atom"

        url = StoryRepository.normalize_url("//blog.golang.org/context", feed_url)
        url.should eq "#{scheme}://blog.golang.org/context"
      end
    end

    it "leaves urls with a scheme intact" do
      input = 'http://blog.golang.org/context'
      normalized_url = StoryRepository.normalize_url(input, 'http://blog.golang.org/feed.atom')
      normalized_url.should eq(input)
    end

    it "falls back to http if the base_url is also sheme less" do
      url = StoryRepository.normalize_url("//blog.golang.org/context", "//blog.golang.org/feed.atom")
      url.should eq 'http://blog.golang.org/context'
    end
  end
end
