# frozen_string_literal: true

describe MarkAsUnread do
  describe "#mark_as_unread" do
    let(:story) { create(:story, is_read: true) }

    it "marks a story as unread" do
      expect { described_class.new(story.id).mark_as_unread }
        .to change { Story.find(story.id).is_read }
        .to(false)
    end
  end
end
