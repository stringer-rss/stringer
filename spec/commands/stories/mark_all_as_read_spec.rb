require "spec_helper"

app_require "commands/stories/mark_all_as_read"

describe MarkAllAsRead do
  describe "#mark_as_read should remain stories keep unread" do
    let(:stories) { stub }
    let(:repo){ stub(fetch_by_ids_without_keep_unread: stories) }
    
    it "marks all stories as read exclude keep_unread: true" do
      command = MarkAllAsRead.new([1, 2], repo)
      stories.should_receive(:update_all).with(is_read: true)
      command.mark_as_read
    end
  end
end