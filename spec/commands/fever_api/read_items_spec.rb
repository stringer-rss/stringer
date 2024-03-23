# frozen_string_literal: true

RSpec.describe FeverAPI::ReadItems do
  it "returns a list of unread items including total count" do
    stories = create_list(:story, 3)
    authorization = Authorization.new(default_user)

    items = stories.map(&:as_fever_json)
    expect(described_class.call(authorization:, items: nil))
      .to eq(items:, total_items: 3)
  end

  it "returns a list of unread items with empty since_id" do
    stories = create_list(:story, 3)
    authorization = Authorization.new(default_user)

    items = stories.map(&:as_fever_json)
    expect(described_class.call(authorization:, items: nil, since_id: ""))
      .to eq(items:, total_items: 3)
  end

  it "returns a list of unread items since id including total count" do
    story, *other_stories = create_list(:story, 3)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, items: nil, since_id: story.id))
      .to eq(items: other_stories.map(&:as_fever_json), total_items: 3)
  end

  it "returns a list of specified items including total count" do
    _story1, *other_stories = create_list(:story, 3)
    with_ids = other_stories.map(&:id)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, items: nil, with_ids:)).to eq(
      items: other_stories.reverse.map(&:as_fever_json),
      total_items: 2
    )
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
