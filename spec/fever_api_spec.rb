# frozen_string_literal: true

require "spec_helper"

describe FeverAPI, type: :controller do
  let(:api_key) { "apisecretkey" }
  let(:story_one) { build(:story) }
  let(:story_two) { build(:story) }
  let(:group) { build(:group) }
  let(:feed) { build(:feed, group:) }
  let(:stories) { [story_one, story_two] }
  let(:standard_answer) do
    { api_version: 3, auth: 1, last_refreshed_on_time: 123456789 }
  end
  let(:cannot_auth) { { api_version: 3, auth: 0 } }

  before { allow(Time).to receive(:now) { Time.at(123456789) } }

  def last_response_as_object
    JSON.parse(last_response.body, symbolize_names: true)
  end

  def params(user: create(:user), **overrides)
    { api_key: user.api_key, **overrides }
  end

  describe "authentication" do
    it "authenticates request with correct api_key" do
      get("/fever", params:)
      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "does not authenticate request with incorrect api_key" do
      get "/fever", params: params(api_key: "foo")
      expect(last_response).to be_ok
      expect(last_response_as_object).to include(cannot_auth)
    end

    it "does not authenticate request when api_key is not provided" do
      create(:user)

      get "/fever", params: params(api_key: nil)
      expect(last_response).to be_ok
      expect(last_response_as_object).to include(cannot_auth)
    end
  end

  describe "#get" do
    it "returns standard answer" do
      get("/fever", params:)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "returns groups and feeds by groups when 'groups' header is provided" do
      group = create(:group)
      feed = create(:feed, group:)

      get("/fever", params: params(groups: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        groups: [group.as_fever_json],
        feeds_groups: [{ group_id: group.id, feed_ids: feed.id.to_s }]
      )
    end

    it "returns feeds and feeds by groups when 'feeds' header is provided" do
      group = create(:group)
      feed = create(:feed, group:)

      get("/fever", params: params(feeds: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        feeds: [feed.as_fever_json],
        feeds_groups: [{ group_id: group.id, feed_ids: feed.id.to_s }]
      )
    end

    it "returns favicons hash when 'favicons' header provided" do
      get("/fever", params: params(favicons: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        favicons: [
          {
            id: 0,
            data: a_string_including("image/gif;base64")
          }
        ]
      )
    end

    it "returns stories when 'items' and 'since_id'" do
      expect(StoryRepository)
        .to receive(:unread_since_id).with("5").and_return([story_one])
      expect(StoryRepository)
        .to receive(:unread).and_return([story_one, story_two])

      get("/fever", params: params(items: nil, since_id: 5))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        items: [story_one.as_fever_json],
        total_items: 2
      )
    end

    it "returns stories when 'items' header is provided without 'since_id'" do
      expect(StoryRepository)
        .to receive(:unread).twice.and_return([story_one, story_two])

      get("/fever", params: params(items: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        items: [story_one.as_fever_json, story_two.as_fever_json],
        total_items: 2
      )
    end

    it "returns stories ids when 'items' and 'with_ids'" do
      expect(StoryRepository)
        .to receive(:fetch_by_ids).twice.with(["5"]).and_return([story_one])

      get("/fever", params: params(items: nil, with_ids: 5))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        items: [story_one.as_fever_json],
        total_items: 1
      )
    end

    it "returns links as empty array when 'links' header is provided" do
      get("/fever", params: params(links: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(links: [])
    end

    it "returns unread items ids when 'unread_item_ids' header is provided" do
      expect(StoryRepository)
        .to receive(:unread).and_return([story_one, story_two])

      get("/fever", params: params(unread_item_ids: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        unread_item_ids: [story_one.id, story_two.id].join(",")
      )
    end

    it "returns starred items when 'saved_item_ids' header is provided" do
      expect(Story).to receive(:where).with(is_starred: true)
                                      .and_return([story_one, story_two])

      get("/fever", params: params(saved_item_ids: nil))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        saved_item_ids: [story_one.id, story_two.id].join(",")
      )
    end
  end

  describe "#post" do
    it "commands to mark story as read" do
      expect(MarkAsRead)
        .to receive(:new).with("10").and_return(double(mark_as_read: true))

      post("/fever", params: params(mark: "item", as: "read", id: 10))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to mark story as unread" do
      expect(MarkAsUnread)
        .to receive(:new).with("10").and_return(double(mark_as_unread: true))

      post("/fever", params: params(mark: "item", as: "unread", id: 10))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to save story" do
      expect(MarkAsStarred)
        .to receive(:new).with("10").and_return(double(mark_as_starred: true))

      post("/fever", params: params(mark: "item", as: "saved", id: 10))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to unsave story" do
      expect(MarkAsUnstarred).to receive(:new)
        .with("10").and_return(double(mark_as_unstarred: true))

      post("/fever", params: params(mark: "item", as: "unsaved", id: 10))

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to mark group as read" do
      expect(MarkGroupAsRead)
        .to receive(:new).with("10", "1375080946")
        .and_return(double(mark_group_as_read: true))

      params = params(mark: "group", as: "read", id: 10, before: 1375080946)
      post("/fever", params:)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to mark entire feed as read" do
      expect(MarkFeedAsRead)
        .to receive(:new).with("20", "1375080945")
        .and_return(double(mark_feed_as_read: true))

      params = params(mark: "feed", as: "read", id: 20, before: 1375080945)
      post("/fever", params:)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end
  end
end
