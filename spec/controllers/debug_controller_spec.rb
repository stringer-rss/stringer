require "spec_helper"

app_require "controllers/debug_controller"

describe "DebugContoller" do
  describe "GET /debug" do
    it "displays the current Ruby version" do
      get "/debug"

      page = last_response.body
      page.should have_tag("dd", text: /#{RUBY_VERSION}/)
    end
  end
end
