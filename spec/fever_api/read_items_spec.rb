require "spec_helper"

app_require "fever_api/read_items"

describe FeverAPI::ReadItems do
  let(:story_repository) { double("repo") }

  subject do
    FeverAPI::ReadItems.new(story_repository: story_repository)
  end

  it "returns a list of unread items including total count" do
    stories = [
      double("story", as_fever_json: { id: 5 }),
      double("story", as_fever_json: { id: 7 }),
      double("story", as_fever_json: { id: 11 })
    ]
    expect(story_repository).to receive(:unread).twice.and_return(stories)
    expect(subject.call("items" => nil)).to eq(
      items: [
        { id: 5 },
        { id: 7 },
        { id: 11 }
      ],
      total_items: 3
    )
  end

  it "returns a list of unread items since id including total count" do
    unread_since_stories = [
      double("story", as_fever_json: { id: 5 }),
      double("story", as_fever_json: { id: 7 })
    ]
    expect(story_repository).to receive(:unread_since_id).with(3).and_return(unread_since_stories)
    unread_stories = [
      double("story", as_fever_json: { id: 2 }),
      double("story", as_fever_json: { id: 5 }),
      double("story", as_fever_json: { id: 7 })
    ]
    expect(story_repository).to receive(:unread).and_return(unread_stories)
    expect(subject.call("items" => nil, since_id: 3)).to eq(
      items: [
        { id: 5 },
        { id: 7 }
      ],
      total_items: 3
    )
  end

  it "returns a list of specified items including total count" do
    stories = [
      double("story", as_fever_json: { id: 5 }),
      double("story", as_fever_json: { id: 11 })
    ]
    expect(story_repository).to receive(:fetch_by_ids).with(%w(5 11)).twice.and_return(stories)

    expect(subject.call("items" => nil, with_ids: "5,11")).to eq(
      items: [
        { id: 5 },
        { id: 11 }
      ],
      total_items: 2
    )
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
