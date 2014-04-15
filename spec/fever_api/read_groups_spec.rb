require "spec_helper"

app_require "fever_api/read_groups"

describe FeverAPI::ReadGroups do
  let(:group_1) { double('group_1', as_fever_json: { id: 1, title: 'IT news' }) }
  let(:group_2) { double('group_2', as_fever_json: { id: 2, title: 'World news' }) }
  let(:group_repository) { double('repo') }

  subject { FeverAPI::ReadGroups.new(group_repository: group_repository) }

  it "returns a group list if requested" do
    group_repository.should_receive(:list).and_return([group_1, group_2])
    subject.call('groups' => nil).should == {
      groups: [
        {
          id: 1,
          title: "IT news"
        },
        {
          id: 2,
          title: 'World news'
        }
      ]
    }
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
