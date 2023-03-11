# frozen_string_literal: true

RSpec.describe MarkAsStarred do
  describe "#mark_as_starred" do
    it "marks a story as starred" do
      story = create(:story)

      expect { described_class.call(story.id) }
        .to change_record(story, :is_starred).from(false).to(true)
    end
  end
end
