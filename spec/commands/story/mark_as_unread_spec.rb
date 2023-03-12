# frozen_string_literal: true

RSpec.describe MarkAsUnread do
  it "marks a story as unread" do
    story = create(:story, is_read: true)

    expect { described_class.call(story.id) }
      .to change_record(story, :is_read).from(true).to(false)
  end
end
