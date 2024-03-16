# frozen_string_literal: true

RSpec.describe FeverAPI::ReadGroups do
  it "returns a group list if requested" do
    groups = create_pair(:group)
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:, groups: nil))
      .to eq(groups: [Group::UNGROUPED, *groups].map(&:as_fever_json))
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
