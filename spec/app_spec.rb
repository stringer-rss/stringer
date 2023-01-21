# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

describe "App" do
  include ControllerHelpers

  describe "Rails" do
    it "returns a fake application" do
      expect(Rails.application.config.cache_classes).to be(true)
    end
  end

  context "when user is not authenticated and page requires authentication" do
    it "sets the session redirect_to" do
      create(:user)

      get("/news")

      expect(session[:redirect_to]).to eq("/news")
    end

    it "redirects to /login" do
      create(:user)

      get("/news")

      expect(last_response).to be_redirect
      expect(last_response.headers["Location"]).to end_with("/login")
    end
  end

  it "does not redirect when page needs no authentication" do
    create(:user)

    get("/login")

    expect(last_response).not_to be_redirect
  end

  it "does not redirect when user is authenticated" do
    login_as(create(:user))

    get("/news")

    expect(last_response).not_to be_redirect
  end

  it "redirects '/' to '/news'" do
    login_as(create(:user))

    get("/")

    expect(last_response).to be_redirect
    expect(last_response.headers["Location"]).to end_with("/news")
  end
end
