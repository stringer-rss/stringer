require "spec_helper"

app_require "commands/stories/mark_as_starred"

describe MarkAsStarred do
  describe "#mark_as_starred" do
    let(:story) { double }
    let(:repo){ double(fetch: story) }

    it "marks a story as starred" do
      command = MarkAsStarred.new(1, repo)
      story.should_receive(:update_attributes).with(is_starred: true)
      command.mark_as_starred
    end
  end
end
