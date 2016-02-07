require "spec_helper"
require "./fever_api"

describe FeverAPI do
  include Rack::Test::Methods

  def app
    FeverAPI::Endpoint
  end

  let(:api_key) { "apisecretkey" }
  let(:story_one) { StoryFactory.build }
  let(:story_two) { StoryFactory.build }
  let(:group) { GroupFactory.build }
  let(:feed) { FeedFactory.build(group_id: group.id) }
  let(:stories) { [story_one, story_two] }
  let(:standard_answer) do
    { api_version: 3, auth: 1, last_refreshed_on_time: 123456789 }
  end
  let(:headers) { { api_key: api_key } }

  before do
    user = double(api_key: api_key)
    allow(User).to receive(:first) { user }

    allow(Time).to receive(:now) { Time.at(123456789) }
  end

  def last_response_as_object
    JSON.parse(last_response.body, symbolize_names: true)
  end

  describe "authentication" do
    it "authenticates request with correct api_key" do
      get "/", headers
      expect(last_response).to be_ok
    end

    it "does not authenticate request with incorrect api_key" do
      get "/", api_key: "foo"
      expect(last_response).not_to be_ok
    end

    it "does not authenticate request when api_key is not provided" do
      get "/"
      expect(last_response).not_to be_ok
    end
  end

  describe "#get" do
    def make_request(extra_headers = {})
      get "/", headers.merge(extra_headers)
    end

    it "returns standard answer" do
      make_request

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "returns groups and feeds by groups when 'groups' header is provided" do
      allow(GroupRepository).to receive(:list).and_return([group])
      allow(FeedRepository).to receive_message_chain(:in_group, :order).and_return([feed])

      make_request(groups: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        groups: [group.as_fever_json],
        feeds_groups: [{ group_id: group.id, feed_ids: feed.id.to_s }]
      )
    end

    it "returns feeds and feeds by groups when 'feeds' header is provided" do
      allow(FeedRepository).to receive(:list).and_return([feed])
      allow(FeedRepository).to receive_message_chain(:in_group, :order).and_return([feed])

      make_request(feeds: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        feeds: [feed.as_fever_json],
        feeds_groups: [{ group_id: group.id, feed_ids: feed.id.to_s }]
      )
    end

    it "returns favicons hash when 'favicons' header provided" do
      make_request(favicons: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        favicons: [
          {
            id: 0,
            data: "image/gif;base64,R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
          }
        ]
      )
    end

    it "returns stories when 'items' header is provided along with 'since_id'" do
      expect(StoryRepository).to receive(:unread_since_id).with("5").and_return([story_one])
      expect(StoryRepository).to receive(:unread).and_return([story_one, story_two])

      make_request(items: nil, since_id: 5)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        items: [story_one.as_fever_json],
        total_items: 2
      )
    end

    it "returns stories when 'items' header is provided without 'since_id'" do
      expect(StoryRepository).to receive(:unread).twice.and_return([story_one, story_two])

      make_request(items: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        items: [story_one.as_fever_json, story_two.as_fever_json],
        total_items: 2
      )
    end

    it "returns stories ids when 'items' header is provided along with 'with_ids'" do
      expect(StoryRepository).to receive(:fetch_by_ids).twice.with(["5"]).and_return([story_one])

      make_request(items: nil, with_ids: 5)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        items: [story_one.as_fever_json],
        total_items: 1
      )
    end

    it "returns links as empty array when 'links' header is provided" do
      make_request(links: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(links: [])
    end

    it "returns unread items ids when 'unread_item_ids' header is provided" do
      expect(StoryRepository).to receive(:unread).and_return([story_one, story_two])

      make_request(unread_item_ids: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        unread_item_ids: [story_one.id, story_two.id].join(",")
      )
    end

    it "returns starred items when 'saved_item_ids' header is provided" do
      expect(Story).to receive(:where).with(is_starred: true).and_return([story_one, story_two])

      make_request(saved_item_ids: nil)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
      expect(last_response_as_object).to include(
        saved_item_ids: [story_one.id, story_two.id].join(",")
      )
    end
  end

  describe "#post" do
    def make_request(extra_headers = {})
      post "/", headers.merge(extra_headers)
    end

    it "commands to mark story as read" do
      expect(MarkAsRead).to receive(:new).with("10").and_return(double(mark_as_read: true))

      make_request(mark: "item", as: "read", id: 10)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to mark story as unread" do
      expect(MarkAsUnread).to receive(:new).with("10").and_return(double(mark_as_unread: true))

      make_request(mark: "item", as: "unread", id: 10)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to save story" do
      expect(MarkAsStarred).to receive(:new).with("10").and_return(double(mark_as_starred: true))

      make_request(mark: "item", as: "saved", id: 10)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to unsave story" do
      expect(MarkAsUnstarred).to receive(:new).with("10").and_return(double(mark_as_unstarred: true))

      make_request(mark: "item", as: "unsaved", id: 10)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to mark group as read" do
      expect(MarkGroupAsRead).to receive(:new).with("10", "1375080946").and_return(double(mark_group_as_read: true))

      make_request(mark: "group", as: "read", id: 10, before: 1375080946)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end

    it "commands to mark entire feed as read" do
      expect(MarkFeedAsRead).to receive(:new).with("20", "1375080945").and_return(double(mark_feed_as_read: true))

      make_request(mark: "feed", as: "read", id: 20, before: 1375080945)

      expect(last_response).to be_ok
      expect(last_response_as_object).to include(standard_answer)
    end
  end
end
