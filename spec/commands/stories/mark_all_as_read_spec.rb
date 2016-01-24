require "spec_helper"

app_require "commands/stories/mark_all_as_read"

describe MarkAllAsRead do
  describe "#mark_as_read" do
    let(:stories) { double }
    let(:repo) { double(fetch_by_ids: stories) }

    it "marks all stories as read" do
      command = MarkAllAsRead.new([1, 2], repo)
      expect(stories).to receive(:update_all).with(is_read: true)
      command.mark_as_read
    end
  end
end
