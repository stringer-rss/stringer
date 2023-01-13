# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "controllers/sinatra/first_run_controller"

describe "FirstRunController" do
  context "when a user has not been setup" do
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
      expect(URI.parse(last_response.location).path).to eq("/news")
    end

    it "redirects root path to /news" do
      user = create(:user, :setup_complete)
      session = { "rack.session" => { user_id: user.id } }

      get "/", {}, session
      expect(URI.parse(last_response.location).path).to eq("/news")
    end
  end
end
