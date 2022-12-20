require "spec_helper"

app_require "commands/stories/mark_as_read"

describe MarkAsRead do
  describe "#mark_as_read" do
    let(:story) { create(:story, is_read: false) }

    it "marks a story as read" do
      expect { MarkAsRead.new(story.id).mark_as_read }
        .to change { Story.find(story.id).is_read }
        .to(true)
    end
  end
end
