require "spec_helper"

app_require "commands/stories/mark_as_unread"

describe MarkAsUnread do
  describe "#mark_as_unread" do
    let(:story) { double }
    let(:repo){ double(fetch: story) }

    it "marks a story as unread" do
      command = MarkAsUnread.new(1, repo)
      story.should_receive(:update_attributes).with(is_read: false)
      command.mark_as_unread
    end
  end
end


