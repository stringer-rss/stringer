# frozen_string_literal: true

require "spec_helper"
require "will_paginate/array"

app_require "controllers/sinatra/stories_controller"

describe "StoriesController" do
  let(:story_one) { create(:story) }
  let(:story_two) { create(:story) }
  let(:stories) { [story_one, story_two] }

  describe "GET /news" do
    before do
      allow(StoryRepository).to receive(:unread).and_return(stories)
      allow(UserRepository).to receive(:fetch).and_return(double)
    end

    it "display list of unread stories" do
      get "/news"

      expect(last_response.body).to have_tag("#stories")
    end

    it "displays the blog title and article title" do
      expect(StoryRepository).to receive(:unread).and_return([story_one])

      get "/news"

      expect(last_response.body).to include(story_one.headline)
      expect(last_response.body).to include(story_one.source)
    end

    it "displays all user actions" do
      get "/news"

      expect(last_response.body).to have_tag("#mark-all")
      expect(last_response.body).to have_tag("#refresh")
      expect(last_response.body).to have_tag("#feeds")
      expect(last_response.body).to have_tag("#add-feed")
    end

    it "should have correct footer links" do
      get "/news"

      page = last_response.body
      expect(page).to have_tag("a", with: { href: "/feeds/export" })
      expect(page).to have_tag("a", with: { href: "/logout" })
      expect(page).to have_tag(
        "a",
        with: { href: "https://github.com/stringer-rss/stringer" }
      )
    end

    it "displays a zen-like message when there are no unread stories" do
      allow(StoryRepository).to receive(:unread).and_return([])

      get "/news"

      expect(last_response.body).to have_tag("#zen")
    end
  end

  describe "GET /archive" do
    let(:read_one) { build(:story, :read) }
    let(:read_two) { build(:story, :read) }
    let(:stories) { [read_one, read_two].paginate }
    before { allow(StoryRepository).to receive(:read).and_return(stories) }

    it "displays the list of read stories with pagination" do
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
    before { allow(StoryRepository).to receive(:starred).and_return(stories) }

    it "displays the list of starred stories with pagination" do
      get "/starred"

      page = last_response.body
      expect(page).to have_tag("#stories")
      expect(page).to have_tag("div#pagination")
    end
  end

  describe "PUT /stories/:id" do
    before { allow(StoryRepository).to receive(:fetch).and_return(story_one) }
    context "is_read parameter" do
      it "marks a story as read when it is not malformed" do
        expect(story_one).to receive(:save!).once

        put "/stories/#{story_one.id}", { is_read: true }.to_json

        expect(story_one.is_read).to be(true)
      end

      it "marks a story as read when it is malformed" do
        expect(story_one).to receive(:save!).once

        put "/stories/#{story_one.id}", { is_read: "malformed" }.to_json

        expect(story_one.is_read).to be(true)
      end
    end

    context "keep_unread parameter" do
      it "marks a story as permanently unread when it is not malformed" do
        put "/stories/#{story_one.id}", { keep_unread: false }.to_json

        expect(story_one.keep_unread).to be(false)
      end

      it "marks a story as permanently unread when it is malformed" do
        put "/stories/#{story_one.id}", { keep_unread: "malformed" }.to_json

        expect(story_one.keep_unread).to be(true)
      end
    end

    context "is_starred parameter" do
      it "marks a story as permanently starred when it is not malformed" do
        put "/stories/#{story_one.id}", { is_starred: true }.to_json

        expect(story_one.is_starred).to be(true)
      end

      it "marks a story as permanently starred when it is malformed" do
        put "/stories/#{story_one.id}", { is_starred: "malformed" }.to_json

        expect(story_one.is_starred).to be(true)
      end
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
      allow(FeedRepository).to receive(:fetch).and_return(story_one.feed)
      allow(StoryRepository).to receive(:feed).and_return(stories)

      get "/feed/#{story_one.feed.id}"

      expect(last_response.body).to have_tag("#stories")
    end

    it "differentiates between read and unread" do
      allow(FeedRepository).to receive(:fetch).and_return(story_one.feed)
      allow(StoryRepository).to receive(:feed).and_return(stories)

      story_one.is_read = false
      story_two.is_read = true

      get "/feed/#{story_one.feed.id}"

      expect(last_response.body).to have_tag("li", class: "story")
      expect(last_response.body).to have_tag("li", class: "unread")
    end
  end
end
