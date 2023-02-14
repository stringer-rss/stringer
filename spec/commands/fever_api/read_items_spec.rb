# frozen_string_literal: true

require "spec_helper"

describe FeverAPI::ReadItems do
  it "returns a list of unread items including total count" do
    stories = create_list(:story, 3, :unread)

    expect(described_class.call("items" => nil)).to eq(
      items: stories.map(&:as_fever_json),
      total_items: 3
    )
  end

  it "returns a list of unread items since id including total count" do
    story1, *other_stories = create_list(:story, 3, :unread)

    expect(described_class.call("items" => nil, since_id: story1.id)).to eq(
      items: other_stories.map(&:as_fever_json),
      total_items: 3
    )
  end

  it "returns a list of specified items including total count" do
    _story1, *other_stories = create_list(:story, 3)
    with_ids = other_stories.map(&:id)

    expect(described_class.call("items" => nil, with_ids:)).to eq(
      items: other_stories.map(&:as_fever_json),
      total_items: 2
    )
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
