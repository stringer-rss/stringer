require "spec_helper"

app_require "repositories/story_repository"

describe StoryRepository do
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
        result = StoryRepository.sanitize("<code>WM_<wbr>ERROR</code> asdf")
        result.should eq "<code>WM_ERROR</code> asdf"
      end

      it "handles <figure> tag properly" do
        result = StoryRepository.sanitize("<figure>some code</figure>")
        result.should eq "<figure>some code</figure>"
      end
    end
  end
end
