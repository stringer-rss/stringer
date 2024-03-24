# frozen_string_literal: true

RSpec.describe FeverAPI::WriteMarkFeed do
  def params(feed, before:)
    authorization = Authorization.new(feed.user)

    { authorization:, mark: "feed", id: feed.id, before: }
  end

  it "marks the feed stories as read before the given timestamp" do
    feed = create(:feed)
    story = create(:story, feed:, created_at: 1.week.ago)

    expect { described_class.call(**params(feed, before: 1.day.ago.to_i)) }
      .to change { story.reload.is_read? }.from(false).to(true)
  end

  it "does not mark the feed stories as read after the given timestamp" do
    feed = create(:feed)
    story = create(:story, feed:)

    expect { described_class.call(**params(feed, before: 1.day.ago.to_i)) }
      .to not_change { story.reload.is_read? }.from(false)
  end

  it "returns an empty hash otherwise" do
    authorization = Authorization.new(default_user)

    expect(described_class.call(authorization:)).to eq({})
  end
end
