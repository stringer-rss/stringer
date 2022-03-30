require "spec_helper"

app_require "commands/stories/mark_as_starred"

describe MarkAsStarred do
  describe "#mark_as_starred" do
    let(:story) { create_story(is_starred: false) }

    it "marks a story as starred" do
      expect { MarkAsStarred.new(story.id).mark_as_starred }
        .to change { Story.find(story.id).is_starred }
        .to(true)
    end
  end
end
