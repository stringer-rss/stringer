# frozen_string_literal: true

RSpec.describe StoriesController do
  describe "GET /news" do
    it "redirects to the setup page when no user exists" do
      get "/news"

      expect(URI.parse(response.location).path).to eq("/setup/password")
    end

    it "redirects to the login page if not logged in" do
      create(:user)

      get "/news"

      expect(URI.parse(response.location).path).to eq("/login")
    end

    it "display list of unread stories" do
      login_as(default_user)
      create(:story)

      get "/news"

      expect(rendered).to have_css("#stories")
    end

    it "displays the blog title and article title" do
      login_as(default_user)
      story = create(:story)

      get "/news"

      expect(rendered).to have_text(story.headline)
    end

    it "displays all user actions" do
      login_as(default_user)
      create(:story)

      get "/news"

      expect(rendered).to have_css("#mark-all")
    end

    it "has correct footer links" do
      login_as(default_user)
      create(:story)

      get "/news"

      expect(rendered).to have_link("Export").and have_link("Logout")
    end

    it "displays a zen-like message when there are no unread stories" do
      login_as(default_user)

      get "/news"

      expect(rendered).to have_css("#zen")
    end
  end

  describe "#archived" do
    it "displays the list of read stories with pagination" do
      login_as(default_user)
      create(:story, :read)

      get "/archive"

      expect(rendered).to have_css("#stories")
    end
  end

  describe "#starred" do
    it "displays the list of starred stories" do
      login_as(default_user)
      create(:story, :starred)

      get "/starred"

      expect(rendered).to have_css("#stories")
    end
  end

  describe "#update" do
    headers = { "CONTENT_TYPE" => "application/json" }

    it "marks a story as read when it is_read not malformed" do
      login_as(default_user)
      story = create(:story)
      params = { is_read: true }.to_json

      expect { put("/stories/#{story.id}", params:, headers:) }
        .to change_record(story, :is_read).from(false).to(true)
    end

    it "marks a story as read when is_read is malformed" do
      login_as(default_user)
      story = create(:story)
      params = { is_read: "malformed" }.to_json

      expect { put("/stories/#{story.id}", params:, headers:) }
        .to change_record(story, :is_read).from(false).to(true)
    end

    it "marks a story as keep unread when it keep_unread not malformed" do
      login_as(default_user)
      story = create(:story)
      params = { keep_unread: true }.to_json

      expect { put("/stories/#{story.id}", params:, headers:) }
        .to change_record(story, :keep_unread).from(false).to(true)
    end

    it "marks a story as keep unread when keep_unread is malformed" do
      login_as(default_user)
      story = create(:story)
      params = { keep_unread: "malformed" }.to_json

      expect { put("/stories/#{story.id}", params:, headers:) }
        .to change_record(story, :keep_unread).from(false).to(true)
    end

    it "marks a story as starred when is_starred is not malformed" do
      login_as(default_user)
      story = create(:story)
      params = { is_starred: true }.to_json

      expect { put("/stories/#{story.id}", params:, headers:) }
        .to change_record(story, :is_starred).from(false).to(true)
    end

    it "marks a story as starred when is_starred is malformed" do
      login_as(default_user)
      story = create(:story)
      params = { is_starred: "malformed" }.to_json

      expect { put("/stories/#{story.id}", params:, headers:) }
        .to change_record(story, :is_starred).from(false).to(true)
    end
  end

  describe "#mark_all_as_read" do
    it "marks all unread stories as read and reload the page" do
      login_as(default_user)
      stories = create_pair(:story)
      params = { story_ids: stories.map(&:id) }

      expect { post("/stories/mark_all_as_read", params:) }
        .to change_all_records(stories, :is_read).from(false).to(true)
    end
  end
end
