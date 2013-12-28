require "spec_helper"

app_require "commands/stories/mark_group_as_read"

describe MarkGroupAsRead do
  describe "#mark_group_as_read" do
    let(:stories) { double }
    let(:repo){ double(fetch_unread_by_timestamp: stories) }

    it "marks group 0 as read" do
      command = MarkGroupAsRead.new(0, Time.now.to_i, repo)
      stories.should_receive(:update_all).with(is_read: true)
      command.mark_group_as_read
    end

    it "marks group 1 as read" do
      command = MarkGroupAsRead.new(1, Time.now.to_i, repo)
      stories.should_receive(:update_all).with(is_read: true)
      command.mark_group_as_read
    end

    it "does not mark other groups as read" do
      command = MarkGroupAsRead.new(2, Time.now.to_i, repo)
      stories.should_not_receive(:update_all).with(is_read: true)
      command.mark_group_as_read
    end
  end
end
