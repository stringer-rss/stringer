# frozen_string_literal: true

require "spec_helper"

app_require "fever_api/write_mark_feed"

describe FeverAPI::WriteMarkFeed do
  subject { described_class.new(marker_class:) }

  let(:feed_marker) { double("feed marker") }
  let(:marker_class) { double("marker class") }

  it "instantiates a feed marker and calls mark_feed_as_read if requested" do
    expect(marker_class)
      .to receive(:new).with(5, 1_234_567_890).and_return(feed_marker)
    expect(feed_marker).to receive(:mark_feed_as_read)
    expect(subject.call(mark: "feed", id: 5, before: 1_234_567_890)).to eq({})
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
