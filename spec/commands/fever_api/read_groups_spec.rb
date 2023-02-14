# frozen_string_literal: true

require "spec_helper"

describe FeverAPI::ReadGroups do
  it "returns a group list if requested" do
    groups = create_pair(:group)

    expect(described_class.call("groups" => nil)).to eq(
      groups: groups.map(&:as_fever_json)
    )
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
