# frozen_string_literal: true

RSpec.describe MarkAsStarred do
  describe "#mark_as_starred" do
    let(:story) { create(:story, is_starred: false) }

    it "marks a story as starred" do
      expect { described_class.new(story.id).mark_as_starred }
        .to change { Story.find(story.id).is_starred }
        .to(true)
    end
  end
end
