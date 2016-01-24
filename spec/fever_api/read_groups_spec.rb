require "spec_helper"

app_require "fever_api/read_groups"

describe FeverAPI::ReadGroups do
  let(:group_1) { double("group_1", as_fever_json: { id: 1, title: "IT news" }) }
  let(:group_2) { double("group_2", as_fever_json: { id: 2, title: "World news" }) }
  let(:group_repository) { double("repo") }

  subject { FeverAPI::ReadGroups.new(group_repository: group_repository) }

  it "returns a group list if requested" do
    expect(group_repository).to receive(:list).and_return([group_1, group_2])
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
