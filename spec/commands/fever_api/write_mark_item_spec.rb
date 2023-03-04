# frozen_string_literal: true

RSpec.describe FeverAPI::WriteMarkItem do
  let(:item_marker) { double("item marker") }
  let(:marker_class) { double("marker class") }

  describe "as read" do
    it "calls mark_item_as_read if requested" do
      story = create(:story, :unread)

      expect { subject.call(mark: "item", as: "read", id: story.id) }
        .to change_record(story, :is_read).from(false).to(true)
    end
  end

  describe "as unread" do
    it "calls mark_item_as_unread if requested" do
      story = create(:story, :read)

      expect { subject.call(mark: "item", as: "unread", id: story.id) }
        .to change_record(story, :is_read).from(true).to(false)
    end
  end

  describe "as starred" do
    it "calls mark_item_as_starred if requested" do
      story = create(:story)

      expect { subject.call(mark: "item", as: "saved", id: story.id) }
        .to change_record(story, :is_starred).from(false).to(true)
    end
  end

  describe "as unstarred" do
    subject { described_class.new(unstarred_marker_class: marker_class) }

    it "calls marks_item_as_unstarred if requested" do
      expect(marker_class).to receive(:new).with(5).and_return(item_marker)
      expect(item_marker).to receive(:mark_as_unstarred)
      expect(subject.call(mark: "item", as: "unsaved", id: 5)).to eq({})
    end
  end

  it "returns an empty hash otherwise" do
    expect(subject.call({ mark: "item" })).to eq({})
  end
end
