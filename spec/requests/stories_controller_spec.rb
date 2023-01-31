# frozen_string_literal: true

require "spec_helper"

describe StoriesController, type: :request do
  let(:story_one) { create(:story) }
  let(:story_two) { create(:story) }
  let(:stories) { [story_one, story_two] }

  describe "GET /news" do
    def setup
      expect(StoryRepository).to receive(:unread).and_return(stories)
    end

    it "redirects to the setup page when no user exists" do
      get "/news"

      expect(URI.parse(last_response.location).path).to eq("/setup/password")
    end

    it "redirects to the login page if not logged in" do
      create(:user)

      get "/news"

      expect(URI.parse(last_response.location).path).to eq("/login")
    end

    it "display list of unread stories" do
      login_as(create(:user))
      setup

      get "/news"

      expect(last_response.body).to have_tag("#stories")
    end

    it "displays the blog title and article title" do
      login_as(create(:user))
      setup

      get "/news"

      expect(last_response.body).to include(story_one.headline)
    end

    it "displays all user actions" do
      login_as(create(:user))
      setup

      get "/news"

      expect(last_response.body).to have_tag("#mark-all")
    end

    it "has correct footer links" do
      login_as(create(:user))
      setup

      get "/news"

      rendered = Capybara.string(last_response.body)
      expect(rendered).to have_link("Export").and have_link("Logout")
    end

    it "displays a zen-like message when there are no unread stories" do
      login_as(create(:user))

      get "/news"

      expect(last_response.body).to have_tag("#zen")
    end
  end

  describe "#archived" do
    it "displays the list of read stories with pagination" do
      login_as(create(:user))
      create(:story, :read)

      get "/archive"

      page = last_response.body
      expect(page).to have_tag("#stories")
    end
  end

  describe "#starred" do
    it "displays the list of starred stories" do
      login_as(create(:user))
      create(:story, :starred)

      get "/starred"

      page = last_response.body
      expect(page).to have_tag("#stories")
    end
  end

  describe "#update" do
    it "marks a story as read when it is_read not malformed" do
      login_as(create(:user))

      put "/stories/#{story_one.id}", params: { is_read: true }.to_json

      expect(story_one.reload.is_read).to be(true)
    end

    it "marks a story as read when is_read is malformed" do
      login_as(create(:user))

      put "/stories/#{story_one.id}", params: { is_read: "malformed" }.to_json

      expect(story_one.reload.is_read).to be(true)
    end

    it "marks a story as keep unread when it keep_unread not malformed" do
      login_as(create(:user))

      put "/stories/#{story_one.id}", params: { keep_unread: false }.to_json

      expect(story_one.reload.keep_unread).to be(false)
    end

    it "marks a story as keep unread when keep_unread is malformed" do
      login_as(create(:user))

      put "/stories/#{story_one.id}",
          params: { keep_unread: "malformed" }.to_json

      expect(story_one.reload.keep_unread).to be(true)
    end

    it "marks a story as starred when is_starred is not malformed" do
      login_as(create(:user))

      put "/stories/#{story_one.id}", params: { is_starred: true }.to_json

      expect(story_one.reload.is_starred).to be(true)
    end

    it "marks a story as starred when is_starred is malformed" do
      login_as(create(:user))

      put "/stories/#{story_one.id}",
          params: { is_starred: "malformed" }.to_json

      expect(story_one.reload.is_starred).to be(true)
    end
  end

  describe "#mark_all_as_read" do
    it "marks all unread stories as read and reload the page" do
      login_as(create(:user))
      stories = create_pair(:story)

      post "/stories/mark_all_as_read", params: { story_ids: stories.map(&:id) }

      expect(stories.map(&:reload).map(&:is_read)).to all(be(true))
    end
  end
end
