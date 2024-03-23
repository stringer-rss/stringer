# frozen_string_literal: true

RSpec.describe FeverAPI::SyncUnreadItemIds do
  it "returns a list of unread items if requested" do
    stories = create_list(:story, 3)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, unread_item_ids: nil))
      .to eq(unread_item_ids: stories.map(&:id).join(","))
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
