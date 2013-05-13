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
  end

  describe ".extract_content" do
    let(:entry) do 
      stub(url: "http://mdswanson.com",
           content: "Some test content<script></script>")
    end

    let(:summary_only) do
      stub(url: "http://mdswanson.com",
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
end
