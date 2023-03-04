# frozen_string_literal: true

RSpec.describe FeverAPI::WriteMarkItem do
  context "when as: 'read'" do
    it "marks the story as read" do
      story = create(:story, :unread)

      expect { subject.call(mark: "item", as: "read", id: story.id) }
        .to change_record(story, :is_read).from(false).to(true)
    end
  end

  context "when as: 'unread'" do
    it "marks the story as unread" do
      story = create(:story, :read)

      expect { subject.call(mark: "item", as: "unread", id: story.id) }
        .to change_record(story, :is_read).from(true).to(false)
    end
  end

  context "when as: 'saved'" do
    it "marks the story as starred" do
      story = create(:story)

      expect { subject.call(mark: "item", as: "saved", id: story.id) }
        .to change_record(story, :is_starred).from(false).to(true)
    end
  end

  context "when as: 'unsaved'" do
    it "marks the story as unstarred" do
      story = create(:story, :starred)

      expect { subject.call(mark: "item", as: "unsaved", id: story.id) }
        .to change_record(story, :is_starred).from(true).to(false)
    end
  end

  it "returns an empty hash when :as is not present" do
    expect(subject.call({ mark: "item" })).to eq({})
  end
end
