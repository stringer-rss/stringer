require "spec_helper"
app_require "repositories/story_repository"

describe StoryRepository do
  klass = described_class

  describe ".urls_to_absolute" do
    it "preserves existing absolute urls" do
      content = '<a href="http://foo">bar</a>'
      expect(klass.urls_to_absolute(content, nil)).to eq(content)
    end

    it "replaces relative urls in a, img and video tags" do
      content = <<-EOS
<div>
<img src="https://foo">
<a href="/bar/baz">tee</a><img src="bar/bar">
<video src="/tee"></video>
</div>
      EOS
      expect(klass.urls_to_absolute(content, "http://oodl.io/d/").gsub(/\n/, ""))
        .to eq((<<-EOS).gsub(/\n/, ""))
<div>
<img src="https://foo">
<a href="http://oodl.io/bar/baz">tee</a>
<img src="http://oodl.io/d/bar/bar">
<video src="http://oodl.io/tee"></video>
</div>
      EOS
    end
  end
end
