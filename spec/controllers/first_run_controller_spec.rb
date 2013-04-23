require "spec_helper"

app_require "controllers/first_run_controller"

describe "FirstRunController" do
  context "when a user has not been setup" do
    before do
      User.stub(:any?).and_return(false)
    end

    describe "GET /password" do
      it "displays a form to enter your password" do
        get "/password"

        page = last_response.body
        page.should have_tag("form#password_setup")
        page.should have_tag("input#password")
        page.should have_tag("input#password-confirmation")
        page.should have_tag("input#submit")
      end
    end

    describe "POST /password" do
      it "rejects empty passwords" do
        post "/password"

        page = last_response.body
        page.should have_tag("div.error")
      end

      it "rejects when password isn't confirmed" do
        post "/password", {password: "foo", password_confirmation: "bar"}

        page = last_response.body
        page.should have_tag("div.error")
      end

      it "accepts confirmed passwords and redirects to next step" do
        CreateUser.any_instance.should_receive(:create).with("foo")

        post "/password", {password: "foo", password_confirmation: "foo"}

        last_response.status.should be 302
        URI::parse(last_response.location).path.should eq "/import"
      end
    end

    describe "GET /import" do
      it "displays the import options" do
        get "/import"

        page = last_response.body
        page.should have_tag("input#opml_file")
        page.should have_tag("a#skip")
      end
    end
  end

  context "when a user has been setup" do
    before do
      User.stub(:any?).and_return(true)
    end

    xit "should redirect any requests to first run stuff" do
      get "/"
      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"

      get "/password"
      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"

      get "/import"
      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"
    end
  end
end