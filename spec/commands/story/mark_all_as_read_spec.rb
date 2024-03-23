# frozen_string_literal: true

RSpec.describe MarkAllAsRead do
  it "marks all stories as read" do
    stories = create_pair(:story)

    expect { described_class.call(stories.map(&:id)) }
      .to change_all_records(stories, :is_read).from(false).to(true)
  end
end
