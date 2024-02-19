# frozen_string_literal: true

RSpec.describe MarkAsRead do
  it "marks a story as read" do
    story = create(:story, is_read: false)

    expect { described_class.call(story.id) }
      .to change_record(story, :is_read).from(false).to(true)
  end
end
