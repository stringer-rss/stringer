# frozen_string_literal: true

RSpec.describe FeverAPI::SyncSavedItemIds do
  it "returns a list of starred items if requested" do
    stories = create_list(:story, 3, :starred)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, saved_item_ids: nil))
      .to eq(saved_item_ids: stories.map(&:id).join(","))
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
