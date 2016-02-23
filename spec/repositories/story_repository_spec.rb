require "spec_helper"

app_require "repositories/story_repository"

describe StoryRepository do
  describe ".add" do
    let(:feed) { double(url: "http://blog.golang.org/feed.atom") }
    before do
      allow(Story).to receive(:create)
    end

    it "normalizes story urls" do
      entry = double(url: "//blog.golang.org/context", title: "", content: "").as_null_object
      expect(StoryRepository).to receive(:normalize_url).with(entry.url, feed.url)

      StoryRepository.add(entry, feed)
    end

    it "sanitizes titles" do
      entry = double(title: "n\u2028\u2029", content: "").as_null_object
      allow(StoryRepository).to receive(:normalize_url)

      expect(Story).to receive(:create).with(hash_including(title: "n"))

      StoryRepository.add(entry, feed)
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
      expect(StoryRepository.extract_content(entry)).to eq "Some test content"
    end

    it "falls back to summary if there is no content" do
      expect(StoryRepository.extract_content(summary_only)).to eq "Dumb publisher"
    end
  end

  describe ".sanitize" do
    context "regressions" do
      it "handles <wbr> tag properly" do
        result = StoryRepository.sanitize("<code>WM_<wbr\t\n >ERROR</code> asdf")
        expect(result).to eq "<code>WM_ERROR</code> asdf"
      end

      it "handles <figure> tag properly" do
        result = StoryRepository.sanitize("<figure>some code</figure>")
        expect(result).to eq "<figure>some code</figure>"
      end

      it "handles unprintable characters" do
        result = StoryRepository.sanitize("n\u2028\u2029")
        expect(result).to eq "n"
      end

      it "preserves line endings" do
        result = StoryRepository.sanitize("test\r\ncase")
        expect(result).to eq "test\r\ncase"
      end
    end
  end
end
