# frozen_string_literal: true

RSpec.describe DebugController do
  describe "GET /debug" do
    def setup
      login_as(default_user)
      expect(Delayed::Job).to receive(:count).and_return(42)

      expect(MigrationStatus)
        .to receive(:call)
        .and_return(["Migration B - 2", "Migration C - 3"])
    end

    it "displays the current Ruby version" do
      setup

      get "/debug"

      expect(rendered).to have_selector("dd", text: /#{RUBY_VERSION}/)
    end

    it "displays the user agent" do
      setup

      get("/debug", headers: { "HTTP_USER_AGENT" => "testy" })

      expect(rendered).to have_selector("dd", text: /testy/)
    end

    it "displays the delayed job count" do
      setup

      get "/debug"

      expect(rendered).to have_selector("dd", text: /42/)
    end

    it "displays pending migrations" do
      setup

      get "/debug"

      expect(rendered).to have_selector("li", text: /Migration B - 2/)
        .and have_selector("li", text: /Migration C - 3/)
    end
  end

  describe "#heroku" do
    it "displays Heroku instructions" do
      get("/heroku")

      expect(rendered).to have_text("add an hourly task")
    end
  end
end
