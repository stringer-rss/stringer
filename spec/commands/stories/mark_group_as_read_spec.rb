require "spec_helper"

app_require "commands/stories/mark_group_as_read"

describe MarkGroupAsRead do
  describe '#mark_group_as_read' do
    let(:stories) { double }
    let(:repo) { double }
    let(:timestamp) { Time.now.to_i }

    def run_command(group_id)
      MarkGroupAsRead.new(group_id, timestamp, repo)
    end

    it 'marks group as read' do
      command = run_command(2)
      stories.should_receive(:update_all).with(is_read: true)
      repo.should_receive(:fetch_unread_by_timestamp_and_group).with(timestamp, 2).and_return(stories)
      command.mark_group_as_read
    end

    it 'does not mark any group as read when group is not provided' do
      command = run_command(nil)
      repo.should_not_receive(:fetch_unread_by_timestamp_and_group)
      repo.should_not_receive(:fetch_unread_by_timestamp)
      command.mark_group_as_read
    end

    context 'SPARKS_GROUP_ID and KINDLING_GROUP_ID' do
      before do
        stories.should_receive(:update_all).with(is_read: true)
        repo.should_receive(:fetch_unread_by_timestamp).and_return(stories)
      end

      it 'marks as read all feeds when group is 0' do
        command = run_command(0)
        command.mark_group_as_read
      end

      it 'marks as read all feeds when group is -1' do
        command = run_command(-1)
        command.mark_group_as_read
      end
    end
  end
end
