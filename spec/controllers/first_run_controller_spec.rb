require "spec_helper"

app_require "controllers/first_run_controller"

describe "FirstRunController" do
  context "when a user has not been setup" do
    before do
      UserRepository.stub(:setup_complete?).and_return(false)
    end

    describe "GET /setup/password" do
      it "displays a form to enter your password" do
        get "/setup/password"

        page = last_response.body
        page.should have_tag("form#password_setup")
        page.should have_tag("input#password")
        page.should have_tag("input#password-confirmation")
        page.should have_tag("input#submit")
      end
    end

    describe "POST /setup/password" do
      it "rejects empty passwords" do
        post "/setup/password"

        page = last_response.body
        page.should have_tag("div.error")
      end

      it "rejects when password isn't confirmed" do
        post "/setup/password", {password: "foo", password_confirmation: "bar"}

        page = last_response.body
        page.should have_tag("div.error")
      end

      it "accepts confirmed passwords and redirects to next step" do
        CreateUser.any_instance.should_receive(:create).with("foo").and_return(double(id: 1))

        post "/setup/password", {password: "foo", password_confirmation: "foo"}

        last_response.status.should be 302
        URI::parse(last_response.location).path.should eq "/feeds/import"
      end
    end

    describe "GET /setup/tutorial" do
      let(:user) { double }
      let(:feeds) {[double, double]}

      before do 
        UserRepository.stub(fetch: user)
        Feed.stub(all: feeds)
      end

      it "displays the tutorial and completes setup" do
        CompleteSetup.should_receive(:complete).with(user).once
        FetchFeeds.should_receive(:enqueue).with(feeds).once
        
        get "/setup/tutorial"

        page = last_response.body
        page.should have_tag("#mark-all-instruction")
        page.should have_tag("#refresh-instruction")
        page.should have_tag("#feeds-instruction")
        page.should have_tag("#add-feed-instruction")
        page.should have_tag("#story-instruction")
        page.should have_tag("#start")
      end
    end
  end

  context "when a user has been setup" do
    before do
      UserRepository.stub(:setup_complete?).and_return(true)
    end

    it "should redirect any requests to first run stuff" do
      get "/"
      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"

      get "/setup/password"
      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"

      get "/setup/tutorial"
      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"
    end
  end
end
