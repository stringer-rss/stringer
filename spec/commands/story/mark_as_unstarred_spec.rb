# frozen_string_literal: true

RSpec.describe MarkAsUnstarred do
  it "marks a story as unstarred" do
    story = create(:story, :starred)

    expect { described_class.call(story.id) }
      .to change_record(story, :is_starred).from(true).to(false)
  end
end
