# frozen_string_literal: true

RSpec.describe MarkGroupAsRead do
  describe "#mark_group_as_read" do
    it "marks group as read" do
      story = create(:story, :with_group, created_at: 1.week.ago)
      timestamp = 1.day.ago

      expect { described_class.call(story.group_id, timestamp) }
        .to change_record(story, :is_read).from(false).to(true)
    end

    it "does not mark any group as read when group is not provided" do
      story = create(:story, :with_group, created_at: 1.week.ago)
      timestamp = 1.day.ago

      expect { described_class.call(nil, timestamp) }
        .not_to change_record(story, :is_read).from(false)
    end

    it "marks as read all feeds when group is 0 (KINDLING_GROUP_ID)" do
      story = create(:story, :with_group, created_at: 1.week.ago)
      timestamp = 1.day.ago

      expect { described_class.call(0, timestamp) }
        .to change_record(story, :is_read).from(false).to(true)
    end

    it "marks as read all feeds when group is -1 (SPARKS_GROUP_ID)" do
      story = create(:story, :with_group, created_at: 1.week.ago)
      timestamp = 1.day.ago

      expect { described_class.call(-1, timestamp) }
        .to change_record(story, :is_read).from(false).to(true)
    end
  end
end
