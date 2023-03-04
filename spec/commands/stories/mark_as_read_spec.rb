# frozen_string_literal: true

RSpec.describe MarkAsRead do
  let(:story) { create(:story, is_read: false) }

  it "marks a story as read" do
    expect { described_class.call(story.id) }
      .to change_record(story, :is_read).from(false).to(true)
  end
end
