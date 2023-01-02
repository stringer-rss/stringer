# frozen_string_literal: true

require "spec_helper"
require "will_paginate/array"

app_require "controllers/sinatra/stories_controller"

describe "StoriesController" do
  let(:story_one) { create(:story) }
  let(:story_two) { create(:story) }
  let(:stories) { [story_one, story_two] }

  describe "GET /news" do
    def setup
      expect(StoryRepository).to receive(:unread).and_return(stories)
      expect(UserRepository).to receive(:fetch).twice.and_return(double)
    end

    it "display list of unread stories" do
      setup

      get "/news"

      expect(last_response.body).to have_tag("#stories")
    end

    it "displays the blog title and article title" do
      setup

      get "/news"

      expect(last_response.body).to include(story_one.headline)
      expect(last_response.body).to include(story_one.source)
    end

    it "displays all user actions" do
      setup

      get "/news"

      expect(last_response.body).to have_tag("#mark-all")
      expect(last_response.body).to have_tag("#refresh")
      expect(last_response.body).to have_tag("#feeds")
    end

    it "has correct footer links" do
      setup

      get "/news"

      page = last_response.body
      expect(page).to have_tag("a", with: { href: "/feeds/export" })
      expect(page).to have_tag("a", with: { href: "/logout" })
    end

    it "displays a zen-like message when there are no unread stories" do
      expect(StoryRepository).to receive(:unread).and_return([])

      get "/news"

      expect(last_response.body).to have_tag("#zen")
    end
  end

  describe "GET /archive" do
    let(:read_one) { build(:story, :read) }
    let(:read_two) { build(:story, :read) }
    let(:stories) { [read_one, read_two].paginate }

    it "displays the list of read stories with pagination" do
      expect(StoryRepository).to receive(:read).and_return(stories)

      get "/archive"

      page = last_response.body
      expect(page).to have_tag("#stories")
      expect(page).to have_tag("div#pagination")
    end
  end

  describe "GET /starred" do
    let(:starred_one) { build(:story, :starred) }
    let(:starred_two) { build(:story, :starred) }
    let(:stories) { [starred_one, starred_two].paginate }

    it "displays the list of starred stories with pagination" do
      expect(StoryRepository).to receive(:starred).and_return(stories)

      get "/starred"

      page = last_response.body
      expect(page).to have_tag("#stories")
      expect(page).to have_tag("div#pagination")
    end
  end

  describe "PUT /stories/:id" do
    it "marks a story as read when it is_read not malformed" do
      expect(StoryRepository).to receive(:fetch).and_return(story_one)
      expect(story_one).to receive(:save!).once

      put "/stories/#{story_one.id}", { is_read: true }.to_json

      expect(story_one.is_read).to be(true)
    end

    it "marks a story as read when is_read is malformed" do
      expect(StoryRepository).to receive(:fetch).and_return(story_one)
      expect(story_one).to receive(:save!).once

      put "/stories/#{story_one.id}", { is_read: "malformed" }.to_json

      expect(story_one.is_read).to be(true)
    end

    it "marks a story as keep unread when it keep_unread not malformed" do
      expect(StoryRepository).to receive(:fetch).and_return(story_one)

      put "/stories/#{story_one.id}", { keep_unread: false }.to_json

      expect(story_one.keep_unread).to be(false)
    end

    it "marks a story as keep unread when keep_unread is malformed" do
      expect(StoryRepository).to receive(:fetch).and_return(story_one)

      put "/stories/#{story_one.id}", { keep_unread: "malformed" }.to_json

      expect(story_one.keep_unread).to be(true)
    end

    it "marks a story as starred when is_starred is not malformed" do
      expect(StoryRepository).to receive(:fetch).and_return(story_one)

      put "/stories/#{story_one.id}", { is_starred: true }.to_json

      expect(story_one.is_starred).to be(true)
    end

    it "marks a story as starred when is_starred is malformed" do
      expect(StoryRepository).to receive(:fetch).and_return(story_one)

      put "/stories/#{story_one.id}", { is_starred: "malformed" }.to_json

      expect(story_one.is_starred).to be(true)
    end
  end

  describe "POST /stories/mark_all_as_read" do
    it "marks all unread stories as read and reload the page" do
      expect(MarkAllAsRead).to receive(:call).once

      post "/stories/mark_all_as_read", story_ids: ["1", "2", "3"]

      expect(last_response.status).to be(302)
      expect(URI.parse(last_response.location).path).to eq("/news")
    end
  end

  describe "GET /feed/:feed_id" do
    it "looks for a particular feed" do
      expect(FeedRepository).to receive(:fetch)
        .with(story_one.feed.id.to_s).and_return(story_one.feed)
      expect(StoryRepository)
        .to receive(:feed).with(story_one.feed.id.to_s).and_return([story_one])

      get "/feed/#{story_one.feed.id}"
    end

    it "displays a list of stories" do
      expect(FeedRepository).to receive(:fetch).and_return(story_one.feed)
      expect(StoryRepository).to receive(:feed).and_return(stories)

      get "/feed/#{story_one.feed.id}"

      expect(last_response.body).to have_tag("#stories")
    end
  end
end
