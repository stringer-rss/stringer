# frozen_string_literal: true

RSpec.describe FeverAPI::ReadFeedsGroups do
  it "returns a list of groups requested through feeds" do
    group = create(:group)
    feeds = create_list(:feed, 3, group:)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, feeds: nil)).to eq(
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
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, groups: nil)).to eq(
      feeds_groups: [
        {
          group_id: group.id,
          feed_ids: feeds.map(&:id).join(",")
        }
      ]
    )
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
