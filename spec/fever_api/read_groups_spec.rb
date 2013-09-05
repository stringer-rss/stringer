require "spec_helper"

app_require "fever_api/read_groups"

describe FeverAPI::ReadGroups do
  subject { FeverAPI::ReadGroups.new }

  it "returns a fixed group list if requested" do
    subject.call('groups' => nil).should == {
      groups: [
        {
          id: 1,
          title: "All items"
        }
      ]
    }
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
