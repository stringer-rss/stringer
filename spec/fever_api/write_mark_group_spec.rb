require "spec_helper"

app_require "fever_api/write_mark_group"

describe FeverAPI::WriteMarkGroup do
  let(:group_marker) { double('group marker') }
  let(:marker_class) { double('marker class') }

  subject do
    FeverAPI::WriteMarkGroup.new(marker_class: marker_class)
  end

  it "instantiates a group marker and calls mark_group_as_read if requested" do
    marker_class.should_receive(:new).with(5, 1234567890).and_return(group_marker)
    group_marker.should_receive(:mark_group_as_read)
    subject.call(mark: 'group', id: 5, before: 1234567890).should == {}
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
