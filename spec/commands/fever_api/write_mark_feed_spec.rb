# frozen_string_literal: true

require "spec_helper"

describe FeverAPI::WriteMarkFeed do
  let(:feed_marker) { double("feed marker") }
  let(:marker_class) { double("marker class") }

  it "marks the feed as read before the given timestamp" do
    feed = create(:feed)
    story_1 = create(:story, :unread, feed:, created_at: 1.week.ago)
    story_2 = create(:story, :unread, feed:)

    expect { described_class.call(mark: "feed", id: feed.id, before: 1.day.ago.to_i) }
      .to change { story_1.reload.is_read? }.from(false).to(true)
      .and not_change { story_2.reload.is_read? }.from(false)
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
