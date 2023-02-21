# frozen_string_literal: true

RSpec.describe MarkAsUnstarred do
  describe "#mark_as_unstarred" do
    let(:story) { create(:story, is_starred: true) }

    it "marks a story as unstarred" do
      expect { described_class.new(story.id).mark_as_unstarred }
        .to change { Story.find(story.id).is_starred }
        .to(false)
    end
  end
end
