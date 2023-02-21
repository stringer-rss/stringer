# frozen_string_literal: true

describe FeverAPI::SyncUnreadItemIds do
  it "returns a list of unread items if requested" do
    stories = create_list(:story, 3, :unread)
    expect(described_class.call("unread_item_ids" => nil))
      .to eq(unread_item_ids: stories.map(&:id).join(","))
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
