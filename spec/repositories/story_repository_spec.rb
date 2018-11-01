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

    it "deletes line and paragraph separator characters from titles" do
      entry = double(title: "n\u2028\u2029", content: "").as_null_object
      allow(StoryRepository).to receive(:normalize_url)

      expect(Story).to receive(:create).with(hash_including(title: "n"))

      StoryRepository.add(entry, feed)
    end

    it "deletes script tags from titles" do
      entry = double(title: "n<script>alert('xss');</script>", content: "").as_null_object
      allow(StoryRepository).to receive(:normalize_url)

      expect(Story).to receive(:create).with(hash_including(title: "n"))

      StoryRepository.add(entry, feed)
    end
  end

  describe ".extract_url" do
    it "returns the url" do
      feed = double(url: "http://github.com")
      entry = double(url: "https://github.com/swanson/stringer")

      expect(StoryRepository.extract_url(entry, feed)).to eq "https://github.com/swanson/stringer"
    end

    it "returns the enclosure_url when the url is nil" do
      feed = double(url: "http://github.com")
      entry = double(url: nil, enclosure_url: "https://github.com/swanson/stringer")

      expect(StoryRepository.extract_url(entry, feed)).to eq "https://github.com/swanson/stringer"
    end

    it "does not crash if url is nil but enclosure_url does not exist" do
      feed = double(url: "http://github.com")
      entry = double(url: nil)

      expect(StoryRepository.extract_url(entry, feed)).to eq nil
    end
  end

  describe ".extract_title" do
    let(:entry) do
    end

    it "returns the title if there is a title" do
      entry = double(title: "title", summary: "summary")

      expect(StoryRepository.extract_title(entry)).to eq "title"
    end

    it "returns the summary if there isn't a title" do
      entry = double(title: "", summary: "summary")

      expect(StoryRepository.extract_title(entry)).to eq "summary"
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

    it "expands urls" do
      entry = double(url: "http://mdswanson.com",
                     content: nil,
                     summary: "<a href=\"page\">Page</a>")

      expect(StoryRepository.extract_content(entry)).to eq "<a href=\"http://mdswanson.com/page\">Page</a>"
    end

    it "ignores URL expansion if entry url is nil" do
      entry = double(url: nil,
                     content: nil,
                     summary: "<a href=\"page\">Page</a>")

      expect(StoryRepository.extract_content(entry)).to eq "<a href=\"page\">Page</a>"
    end
  end
end
