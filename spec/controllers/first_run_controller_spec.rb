# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "controllers/sinatra/first_run_controller"

describe "FirstRunController" do
  context "when a user has not been setup" do
    def setup
      expect(UserRepository)
        .to receive(:setup_complete?).twice.and_return(false)
    end

    describe "GET /setup/password" do
      it "displays a form to enter your password" do
        setup

        get "/setup/password"

        page = last_response.body
        expect(page).to have_tag("form#password_setup")
        expect(page).to have_tag("input#password")
      end
    end

    describe "POST /setup/password" do
      it "rejects empty passwords" do
        setup

        post "/setup/password"

        page = last_response.body
        expect(page).to have_tag("div.error")
      end

      it "rejects when password isn't confirmed" do
        setup

        post "/setup/password", password: "foo", password_confirmation: "bar"

        page = last_response.body
        expect(page).to have_tag("div.error")
      end

      it "accepts confirmed passwords and redirects to next step" do
        setup
        user = instance_double(User, id: 1)
        expect(CreateUser).to receive(:call).with("foo").and_return(user)

        post "/setup/password", password: "foo", password_confirmation: "foo"

        expect(URI.parse(last_response.location).path).to eq("/feeds/import")
      end
    end

    describe "GET /setup/tutorial" do
      let(:user) { instance_double(User) }
      let(:feeds) { [instance_double(Feed), instance_double(Feed)] }

      it "displays the tutorial and completes setup" do
        user = create(:user)

        get "/setup/tutorial", {}, { "rack.session" => { user_id: user.id } }

        page = last_response.body
        expect(page).to have_tag("#mark-all-instruction")
      end
    end
  end

  context "when a user has been setup" do
    it "redirects tutorial path to /news" do
      user = create(:user, :setup_complete)
      session = { "rack.session" => { user_id: user.id } }

      get "/setup/tutorial", {}, session
      expect(last_response.status).to be(302)
      expect(URI.parse(last_response.location).path).to eq("/news")
    end

    it "redirects root path to /news" do
      user = create(:user, :setup_complete)
      session = { "rack.session" => { user_id: user.id } }

      get "/", {}, session
      expect(last_response.status).to be(302)
      expect(URI.parse(last_response.location).path).to eq("/news")
    end
  end
end
