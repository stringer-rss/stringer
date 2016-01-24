require "spec_helper"

app_require "controllers/first_run_controller"

describe "FirstRunController" do
  context "when a user has not been setup" do
    before do
      allow(UserRepository).to receive(:setup_complete?).and_return(false)
    end

    describe "GET /setup/password" do
      it "displays a form to enter your password" do
        get "/setup/password"

        page = last_response.body
        expect(page).to have_tag("form#password_setup")
        expect(page).to have_tag("input#password")
        expect(page).to have_tag("input#password-confirmation")
        expect(page).to have_tag("input#submit")
      end
    end

    describe "POST /setup/password" do
      it "rejects empty passwords" do
        post "/setup/password"

        page = last_response.body
        expect(page).to have_tag("div.error")
      end

      it "rejects when password isn't confirmed" do
        post "/setup/password", password: "foo", password_confirmation: "bar"

        page = last_response.body
        expect(page).to have_tag("div.error")
      end

      it "accepts confirmed passwords and redirects to next step" do
        expect_any_instance_of(CreateUser).to receive(:create).with("foo").and_return(double(id: 1))

        post "/setup/password", password: "foo", password_confirmation: "foo"

        expect(last_response.status).to be 302
        expect(URI.parse(last_response.location).path).to eq "/feeds/import"
      end
    end

    describe "GET /setup/tutorial" do
      let(:user) { double }
      let(:feeds) { [double, double] }

      before do
        allow(UserRepository).to receive(:fetch).and_return(user)
        allow(Feed).to receive(:all).and_return(feeds)
      end

      it "displays the tutorial and completes setup" do
        expect(CompleteSetup).to receive(:complete).with(user).once
        expect(FetchFeeds).to receive(:enqueue).with(feeds).once

        get "/setup/tutorial"

        page = last_response.body
        expect(page).to have_tag("#mark-all-instruction")
        expect(page).to have_tag("#refresh-instruction")
        expect(page).to have_tag("#feeds-instruction")
        expect(page).to have_tag("#add-feed-instruction")
        expect(page).to have_tag("#story-instruction")
        expect(page).to have_tag("#start")
      end
    end
  end

  context "when a user has been setup" do
    before do
      allow(UserRepository).to receive(:setup_complete?).and_return(true)
    end

    it "should redirect any requests to first run stuff" do
      get "/"
      expect(last_response.status).to be 302
      expect(URI.parse(last_response.location).path).to eq "/news"

      get "/setup/password"
      expect(last_response.status).to be 302
      expect(URI.parse(last_response.location).path).to eq "/news"

      get "/setup/tutorial"
      expect(last_response.status).to be 302
      expect(URI.parse(last_response.location).path).to eq "/news"
    end
  end
end
