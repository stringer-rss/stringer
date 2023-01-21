# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "controllers/debug_controller"

describe DebugController, type: :controller do
  describe "GET /debug" do
    def setup
      expect(Delayed::Job).to receive(:count).and_return(42)

      migration_status_instance = instance_double(MigrationStatus)
      expect(migration_status_instance)
        .to receive(:pending_migrations)
        .and_return(["Migration B - 2", "Migration C - 3"])
      expect(MigrationStatus)
        .to receive(:new).and_return(migration_status_instance)
    end

    it "displays the current Ruby version" do
      setup

      get "/debug"

      page = last_response.body
      expect(page).to have_tag("dd", text: /#{RUBY_VERSION}/)
    end

    it "displays the user agent" do
      setup

      get "/debug", {}, "HTTP_USER_AGENT" => "test"

      page = last_response.body
      expect(page).to have_tag("dd", text: /test/)
    end

    it "displays the delayed job count" do
      setup

      get "/debug"

      page = last_response.body
      expect(page).to have_tag("dd", text: /42/)
    end

    it "displays pending migrations" do
      setup

      get "/debug"

      rendered = Capybara.string(last_response.body)
      expect(rendered).to have_selector("li", text: /Migration B - 2/)
        .and have_selector("li", text: /Migration C - 3/)
    end
  end

  describe "#heroku" do
    it "displays Heroku instructions" do
      get("/heroku")

      expect(last_response.body).to include("add an hourly task")
    end
  end
end
