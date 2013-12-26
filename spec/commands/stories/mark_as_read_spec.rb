require "spec_helper"

app_require "commands/stories/mark_as_read"

describe MarkAsRead do
  describe "#mark_as_read" do
    let(:story) { double }
    let(:repo){ double(fetch: story) }

    it "marks a story as read" do
      command = MarkAsRead.new(1, repo)
      story.should_receive(:update_attributes).with(is_read: true)
      command.mark_as_read
    end
  end
end

