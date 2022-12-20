# frozen_string_literal: true

require "spec_helper"

app_require "commands/stories/mark_as_unstarred"

describe MarkAsUnstarred do
  describe "#mark_as_unstarred" do
    let(:story) { create(:story, is_starred: true) }

    it "marks a story as unstarred" do
      expect { MarkAsUnstarred.new(story.id).mark_as_unstarred }
        .to change { Story.find(story.id).is_starred }
        .to(false)
    end
  end
end
