# frozen_string_literal: true

describe FeverAPI::WriteMarkItem do
  let(:item_marker) { double("item marker") }
  let(:marker_class) { double("marker class") }

  describe "as read" do
    subject { described_class.new(read_marker_class: marker_class) }

    it "calls mark_item_as_read if requested" do
      expect(marker_class).to receive(:new).with(5).and_return(item_marker)
      expect(item_marker).to receive(:mark_as_read)
      expect(subject.call(mark: "item", as: "read", id: 5)).to eq({})
    end
  end

  describe "as unread" do
    subject { described_class.new(unread_marker_class: marker_class) }

    it "calls mark_item_as_unread if requested" do
      expect(marker_class).to receive(:new).with(5).and_return(item_marker)
      expect(item_marker).to receive(:mark_as_unread)
      expect(subject.call(mark: "item", as: "unread", id: 5)).to eq({})
    end
  end

  describe "as starred" do
    subject { described_class.new(starred_marker_class: marker_class) }

    it "calls mark_item_as_starred if requested" do
      expect(marker_class).to receive(:new).with(5).and_return(item_marker)
      expect(item_marker).to receive(:mark_as_starred)
      expect(subject.call(mark: "item", as: "saved", id: 5)).to eq({})
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
