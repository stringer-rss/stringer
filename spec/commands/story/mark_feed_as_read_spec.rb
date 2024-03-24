# frozen_string_literal: true

RSpec.describe MarkFeedAsRead do
  it "marks feed stories as read before timestamp" do
    story = create(:story, created_at: 1.week.ago)
    before = 1.day.ago

    expect { described_class.call(story.feed_id, before) }
      .to change_record(story, :is_read).from(false).to(true)
  end
end
