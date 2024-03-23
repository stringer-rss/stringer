# frozen_string_literal: true

RSpec.describe FeverAPI::WriteMarkItem do
  context "when as: 'read'" do
    it "marks the story as read" do
      story = create(:story)
      authorization = Authorization.new(story.user)
      params = { authorization:, mark: "item", as: "read", id: story.id }

      expect { subject.call(**params) }
        .to change_record(story, :is_read).from(false).to(true)
    end
  end

  context "when as: 'unread'" do
    it "marks the story as unread" do
      story = create(:story, :read)
      authorization = Authorization.new(story.user)
      params = { authorization:, mark: "item", as: "unread", id: story.id }

      expect { subject.call(**params) }
        .to change_record(story, :is_read).from(true).to(false)
    end
  end

  context "when as: 'saved'" do
    it "marks the story as starred" do
      story = create(:story)
      authorization = Authorization.new(story.user)
      params = { authorization:, mark: "item", as: "saved", id: story.id }

      expect { subject.call(**params) }
        .to change_record(story, :is_starred).from(false).to(true)
    end
  end

  context "when as: 'unsaved'" do
    it "marks the story as unstarred" do
      story = create(:story, :starred)
      authorization = Authorization.new(story.user)
      params = { authorization:, mark: "item", as: "unsaved", id: story.id }

      expect { subject.call(**params) }
        .to change_record(story, :is_starred).from(true).to(false)
    end
  end

  it "returns an empty hash when :as is not present" do
    authorization = Authorization.new(default_user)

    expect(subject.call(authorization:, mark: "item")).to eq({})
  end
end
