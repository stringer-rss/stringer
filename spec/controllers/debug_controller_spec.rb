require "spec_helper"

app_require "controllers/debug_controller"

describe "DebugContoller" do
  describe "GET /debug" do
    before do
      delayed_job = double "Delayed::Job"
      delayed_job.stub(:count).and_return(42)
      stub_const("Delayed::Job", delayed_job)
    end

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

    it "displays the delayed job count" do
      get "/debug"

      page = last_response.body
      page.should have_tag("dd", text: /42/)
    end
  end
end
