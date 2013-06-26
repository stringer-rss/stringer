require "spec_helper"

app_require "controllers/debug_controller"

describe "DebugContoller" do
  describe "GET /debug" do
    it "displays the current Ruby version" do
      get "/debug"

      page = last_response.body
      page.should have_tag("dd", text: /#{RUBY_VERSION}/)
    end

    it "displays the user agent" do
      get "/debug", {}, { "HTTP_USER_AGENT" => "test" }

      page = last_response.body
      page.should have_tag("dd", text: /test/)
    end
  end
end
