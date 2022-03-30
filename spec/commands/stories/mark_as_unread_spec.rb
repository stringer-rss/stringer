require "spec_helper"

app_require "commands/stories/mark_as_unread"

describe MarkAsUnread do
  describe "#mark_as_unread" do
    let(:story) { create_story(is_read: true) }

    it "marks a story as unread" do
      expect { MarkAsUnread.new(story.id).mark_as_unread }
        .to change { Story.find(story.id).is_read }
        .to(false)
    end
  end
end
