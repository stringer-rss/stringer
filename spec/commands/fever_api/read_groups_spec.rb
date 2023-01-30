# frozen_string_literal: true

require "spec_helper"

describe FeverAPI::ReadGroups do
  subject { described_class.new(group_repository:) }

  let(:group1) { double("group1", as_fever_json: { id: 1, title: "IT news" }) }
  let(:group2) do
    double("group2", as_fever_json: { id: 2, title: "World news" })
  end
  let(:group_repository) { double("repo") }

  it "returns a group list if requested" do
    expect(group_repository).to receive(:list).and_return([group1, group2])
    expect(subject.call("groups" => nil)).to eq(
      groups: [
        {
          id: 1,
          title: "IT news"
        },
        {
          id: 2,
          title: "World news"
        }
      ]
    )
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
