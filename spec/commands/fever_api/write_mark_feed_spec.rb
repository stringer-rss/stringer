# frozen_string_literal: true

RSpec.describe FeverAPI::WriteMarkFeed do
  let(:feed_marker) { double("feed marker") }
  let(:marker_class) { double("marker class") }

  it "marks the feed stories as read before the given timestamp" do
    feed = create(:feed)
    story = create(:story, :unread, feed:, created_at: 1.week.ago)
    before = 1.day.ago.to_i

    expect { described_class.call(mark: "feed", id: feed.id, before:) }
      .to change { story.reload.is_read? }.from(false).to(true)
  end

  it "does not mark the feed stories as read after the given timestamp" do
    feed = create(:feed)
    story = create(:story, :unread, feed:)
    before = 1.day.ago.to_i

    expect { described_class.call(mark: "feed", id: feed.id, before:) }
      .to not_change { story.reload.is_read? }.from(false)
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
