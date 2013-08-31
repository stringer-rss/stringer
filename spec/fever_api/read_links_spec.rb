require "spec_helper"

app_require "fever_api/read_links"

describe FeverAPI::ReadLinks do
  subject { FeverAPI::ReadLinks.new }

  it "returns a fixed link list if requested" do
    subject.call('links' => nil).should == { links: [] }
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
