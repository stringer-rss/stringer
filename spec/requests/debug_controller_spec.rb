# frozen_string_literal: true

RSpec.describe DebugController do
  describe "#debug" do
    def setup
      login_as(create(:user, admin: true))

      expect(MigrationStatus)
        .to receive(:call)
        .and_return(["Migration B - 2", "Migration C - 3"])
    end

    it "displays an admin settings link" do
      setup

      get("/admin/debug")

      expect(rendered).to have_link("Admin Settings", href: settings_path)
    end

    it "displays the current Ruby version" do
      setup

      get "/admin/debug"

      expect(rendered).to have_css("dd", text: /#{RUBY_VERSION}/)
    end

    it "displays the user agent" do
      setup

      get("/admin/debug", headers: { "HTTP_USER_AGENT" => "testy" })

      expect(rendered).to have_css("dd", text: /testy/)
    end

    it "displays the jobs count" do
      setup
      12.times { GoodJob::Job.create!(scheduled_at: Time.zone.now) }

      get "/admin/debug"

      expect(rendered).to have_css("dd", text: /12/)
    end

    it "displays pending migrations" do
      setup

      get "/admin/debug"

      expect(rendered).to have_css("li", text: /Migration B - 2/)
        .and have_css("li", text: /Migration C - 3/)
    end
  end

  describe "#heroku" do
    it "displays Heroku instructions" do
      get("/heroku")

      expect(rendered).to have_text("add an hourly task")
    end
  end
end
