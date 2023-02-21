# frozen_string_literal: true

describe FeverAPI::ReadFeedsGroups do
  it "returns a list of groups requested through feeds" do
    group = create(:group)
    feeds = create_list(:feed, 3, group:)

    expect(described_class.call("feeds" => nil)).to eq(
      feeds_groups: [
        {
          group_id: group.id,
          feed_ids: feeds.map(&:id).join(",")
        }
      ]
    )
  end

  it "returns a list of groups requested through groups" do
    group = create(:group)
    feeds = create_list(:feed, 3, group:)

    expect(described_class.call("groups" => nil)).to eq(
      feeds_groups: [
        {
          group_id: group.id,
          feed_ids: feeds.map(&:id).join(",")
        }
      ]
    )
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
