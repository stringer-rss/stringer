# frozen_string_literal: true

require "spec_helper"

describe SessionsController, type: :request do
  describe "#new" do
    it "has a password input and login button" do
      create(:user)

      get "/login"

      page = last_response.body
      expect(page).to have_tag("input#password")
    end
  end

  describe "#create" do
    it "denies access when password is incorrect" do
      create(:user)
      post "/login", params: { password: "not-the-password" }

      page = last_response.body
      expect(page).to have_tag(".error")
    end

    it "allows access when password is correct" do
      user = create(:user)

      post "/login", params: { password: user.password }

      expect(session[:user_id]).to eq(user.id)
    end

    it "redirects to the root page" do
      user = create(:user)

      post "/login", params: { password: user.password }

      expect(URI.parse(last_response.location).path).to eq("/")
    end

    it "redirects to the previous path when present" do
      user = create(:user)

      params = { password: user.password }
      session[:redirect_to] = "/archive"
      post("/login", params:)

      expect(URI.parse(last_response.location).path).to eq("/archive")
    end
  end

  describe "#destroy" do
    it "clears the session" do
      login_as(create(:user))

      get "/logout"

      expect(session[:user_id]).to be_nil
    end

    it "redirects to the root page" do
      login_as(create(:user))

      get "/logout"

      expect(URI.parse(last_response.location).path).to eq("/")
    end
  end
end
