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

    it "groups stories by feed when the user enables grouping" do
      default_user.update!(group_stories: true)
      login_as(default_user)
      create(:story)

      get "/news"

      expect(rendered).to have_css("#stories")
    end
  end

  describe "#archived" do
    it "displays the list of read stories with pagination" do
      login_as(default_user)
      create(:story, :read)

      get "/archive"

      expect(rendered).to have_css("#stories")
    end

    it "displays a message when there are no read stories" do
      login_as(default_user)

      get "/archive"

      expect(rendered).to have_text("you haven't read any stories yet")
    end
  end

  describe "#starred" do
    it "displays the list of starred stories" do
      login_as(default_user)
      create(:story, :starred)

      get "/starred"

      expect(rendered).to have_css("#stories")
    end

    it "displays a message when there are no starred stories" do
      login_as(default_user)

      get "/starred"

      expect(rendered).to have_text("you haven't starred any stories yet")
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

  describe "#refresh" do
    def updated_entry
      double(
        guid: "entry-guid",
        published: Time.zone.now,
        title: "Updated title",
        url: "https://example.com/updated",
        content: "Updated content",
        enclosure_url: "https://example.com/updated.mp3"
      )
    end

    def stub_updated_feed(feed)
      xml = GenerateXml.call(feed, [updated_entry])
      stub_request(:get, feed.url).to_return(status: 200, body: xml)
    end

    def stub_invalid_feed(feed)
      stub_request(:get, feed.url).to_return(status: 200, body: "not a feed")
    end

    it "updates the story from the feed" do
      login_as(default_user)
      story = create(:story, entry_id: "entry-guid")
      stub_updated_feed(story.feed)

      expect { post("/stories/#{story.id}/refresh") }
        .to change_record(story, :title).to("Updated title")
    end

    def have_story_frame(story, text:)
      have_css("turbo-frame#story_#{story.id}", text:)
    end

    it "renders the refreshed story's Turbo Frame" do
      login_as(default_user)
      story = create(:story, entry_id: "entry-guid")
      stub_updated_feed(story.feed)

      post("/stories/#{story.id}/refresh")

      expect(rendered).to have_story_frame(story, text: "Updated title")
    end

    it "responds with unprocessable content when the refresh fails" do
      login_as(default_user)
      story = create(:story)
      stub_invalid_feed(story.feed)

      post("/stories/#{story.id}/refresh")

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "renders the unchanged story's frame when the refresh fails" do
      login_as(default_user)
      story = create(:story, title: "Old title")
      stub_invalid_feed(story.feed)

      post("/stories/#{story.id}/refresh")

      expect(rendered).to have_story_frame(story, text: "Old title")
    end
  end

  describe "#star" do
    def star(story, starred)
      patch("/stories/#{story.id}/star", params: { starred: starred.to_s })
    end

    def star_targets(story)
      ["preview", "actions"].map { |row| "story_#{story.id}_star_#{row}" }
    end

    it "stars the story" do
      login_as(default_user)
      story = create(:story)

      expect { star(story, true) }
        .to change_record(story, :is_starred).from(false).to(true)
    end

    it "unstars the story" do
      login_as(default_user)
      story = create(:story, :starred)

      expect { star(story, false) }
        .to change_record(story, :is_starred).from(true).to(false)
    end

    it "responds with a Turbo Stream" do
      login_as(default_user)

      star(create(:story), true)

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "replaces both of the story's star buttons" do
      login_as(default_user)
      story = create(:story)

      star(story, true)

      expect(rendered.all("turbo-stream", visible: :all).pluck(:target))
        .to eq(star_targets(story))
    end
  end

  describe "#keep_unread" do
    def keep_unread(story, value)
      patch(
        "/stories/#{story.id}/keep_unread",
        params: { keep_unread: value.to_s }
      )
    end

    it "keeps the story unread" do
      login_as(default_user)
      story = create(:story, :read)

      expect { keep_unread(story, true) }
        .to change_record(story, :keep_unread).from(false).to(true)
        .and change_record(story, :is_read).from(true).to(false)
    end

    it "marks the story read when it stops keeping it unread" do
      login_as(default_user)
      story = create(:story, keep_unread: true)

      expect { keep_unread(story, false) }
        .to change_record(story, :keep_unread).from(true).to(false)
        .and change_record(story, :is_read).from(false).to(true)
    end

    it "replaces the keep unread button with a Turbo Stream" do
      login_as(default_user)
      story = create(:story)

      keep_unread(story, true)

      expect(rendered.find("turbo-stream", visible: :all)[:target])
        .to eq("story_#{story.id}_keep_unread")
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
