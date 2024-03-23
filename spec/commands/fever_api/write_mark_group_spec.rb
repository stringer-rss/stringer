# frozen_string_literal: true

RSpec.describe FeverAPI::WriteMarkGroup do
  def authorization
    Authorization.new(default_user)
  end

  it "marks the group stories as read before the given timestamp" do
    story = create(:story, :with_group, created_at: 1.week.ago)
    before = 1.day.ago
    id = story.group_id

    expect { described_class.call(authorization:, mark: "group", id:, before:) }
      .to change_record(story, :is_read).from(false).to(true)
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call(authorization:)).to eq({})
  end
end
