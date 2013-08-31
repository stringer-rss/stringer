require "spec_helper"

app_require "fever_api/write_mark_feed"

describe FeverAPI::WriteMarkFeed do
  let(:feed_marker) { double('feed marker') }
  let(:marker_class) { double('marker class') }

  subject do
    FeverAPI::WriteMarkFeed.new(marker_class: marker_class)
  end

  it "instantiates a feed marker and calls mark_feed_as_read if requested" do
    marker_class.should_receive(:new).with(5, 1234567890).and_return(feed_marker)
    feed_marker.should_receive(:mark_feed_as_read)
    subject.call(mark: 'feed', id: 5, before: 1234567890).should == {}
  end

  it "returns an empty hash otherwise" do
    subject.call.should == {}
  end
end
