require 'spec_helper'
require './fever_api'

describe FeverAPI do
  include Rack::Test::Methods

  def app
    FeverAPI::Endpoint
  end

  let(:api_key) { 'apisecretkey' }
  let(:story_one) { StoryFactory.build }
  let(:story_two) { StoryFactory.build }
  let(:feed) { FeedFactory.build }
  let(:stories) { [story_one, story_two] }
  let(:answer) { { api_version: 3, auth: 1, last_refreshed_on_time: Time.now.to_i } }
  let(:headers) { { api_key: api_key } }

  before do
    user = double(api_key: api_key)
    User.stub(:first).and_return(user)
  end

  describe "authentication" do
    it "authenticates request with correct api_key" do
      get "/", headers
      last_response.should be_ok
    end

    it "does not authenticate request with incorrect api_key" do
      get "/", api_key: 'foo'
      last_response.should_not be_ok
    end

    it "does not authenticate request when api_key is not provided" do
      get "/"
      last_response.should_not be_ok
    end
  end

  describe "#get" do
    def make_request(extra_headers = {})
      get "/", headers.merge(extra_headers)
    end

    it "returns standart answer" do
      make_request
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns groups and feeds by groups when 'groups' header is provided" do
      FeedRepository.stub(:list).and_return([feed])
      make_request({ groups: nil })
      answer.merge!({ groups: [{ id: 1, title: "All items" }], feeds_groups: [{ group_id: 1, feed_ids: feed.id.to_s }] })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns feeds and feeds by groups when 'feeds' header is provided" do
      Feed.stub(:all).and_return([feed])
      FeedRepository.stub(:list).and_return([feed])
      make_request({ feeds: nil })
      answer.merge!({ feeds: [feed.as_fever_json], feeds_groups: [{ group_id: 1, feed_ids: feed.id.to_s }] })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns favicons hash when 'favicons' header provided" do
      make_request({ favicons: nil })
      answer.merge!({ favicons: [{ id: 0, data: "image/gif;base64,R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==" }] })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns stories when 'items' header is provided along with 'since_id'" do
      StoryRepository.should_receive(:unread_since_id).with('5').and_return([story_one])
      StoryRepository.should_receive(:unread).and_return([story_one, story_two])
      make_request({ items: nil, since_id: 5 })
      answer.merge!({ items: [story_one.as_fever_json], total_items: 2 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns stories when 'items' header is provided without 'since_id'" do
      StoryRepository.should_receive(:unread).twice.and_return([story_one, story_two])
      make_request({ items: nil })
      answer.merge!({ items: [story_one.as_fever_json, story_two.as_fever_json], total_items: 2 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns stories ids when 'items' header is provided along with 'with_ids'" do
      StoryRepository.should_receive(:fetch_by_ids).twice.with(['5']).and_return([story_one])
      make_request({ items: nil, with_ids: 5 })
      answer.merge!({ items: [story_one.as_fever_json], total_items: 1 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns links as empty array when 'links' header is provided" do
      make_request({ links: nil })
      answer.merge!({ links: [] })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns unread items ids when 'unread_item_ids' header is provided" do
      StoryRepository.should_receive(:unread).and_return([story_one, story_two])
      make_request({ unread_item_ids: nil })
      answer.merge!({ unread_item_ids: [story_one.id,story_two.id].join(',') })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "returns starred items when 'saved_item_ids' header is provided" do
      Story.should_receive(:where).with({ is_starred: true }).and_return([story_one, story_two])
      make_request({ saved_item_ids: nil })
      answer.merge!({ saved_item_ids: [story_one.id,story_two.id].join(',') })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end
  end

  describe "#post" do
    def make_request(extra_headers = {})
      post "/", headers.merge(extra_headers)
    end

    it "commands to mark story as read" do
      MarkAsRead.should_receive(:new).with('10').and_return(double(mark_as_read: true))
      make_request({ mark: 'item', as: 'read', id: 10 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "commands to mark story as unread" do
      MarkAsUnread.should_receive(:new).with('10').and_return(double(mark_as_unread: true))
      make_request({ mark: 'item', as: 'unread', id: 10 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "commands to save story" do
      MarkAsStarred.should_receive(:new).with('10').and_return(double(mark_as_starred: true))
      make_request({ mark: 'item', as: 'saved', id: 10 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "commands to unsave story" do
      MarkAsUnstarred.should_receive(:new).with('10').and_return(double(mark_as_unstarred: true))
      make_request({ mark: 'item', as: 'unsaved', id: 10 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end

    it "commands to mark group as read" do
      MarkGroupAsRead.should_receive(:new).with('10', '1375080946').and_return(double(mark_group_as_read: true))
      make_request({ mark: 'group', as: 'read', id: 10, before: 1375080946 })
      last_response.should be_ok
      last_response.body.should == answer.to_json
    end
  end
end
