require "spec_helper"

app_require "controllers/superfeedr_controller"

describe "SuperfeedrController" do
  context "when a user has not configured superfeedr" do
    before do
      UserRepository.stub(:has_superfeedr?).and_return(false)
    end

    describe "GET /config/superfeedr" do
      it "displays a form to enter superfeedr username/password" do
        get "/config/superfeedr"

        page = last_response.body
        page.should have_tag("form#add-superfeedr-setup")
        page.should have_tag("input#superfeedr_username")
        page.should have_tag("input#superfeedr_password")
        page.should have_tag("input#submit")
      end
    end

    describe "POST /config/superfeedr" do
      it "rejects empty superfeedr username/password" do
        post "/config/superfeedr"

        page = last_response.body
        page.should have_tag("div.error")
      end

      it "accepts confirmed superfeedr username/password and redirects to next step" do
        post "/config/superfeedr", {superfeedr_username: "demo", superfeedr_password: "demo"}

        last_response.status.should be 302
        URI::parse(last_response.location).path.should eq "/"
      end
    end
  end

  context "when a user has configured superfeedr" do
    before do
      UserRepository.stub(:has_superfeedr?).and_return(true)
    end

    it "delete superfeedr username/password and redirects to next step" do

      post "/delete/superfeedr", {remove_superfeedr_username: "demo"}

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/"
    end

  end
end