# frozen_string_literal: true

require "spec_helper"

app_require "controllers/sinatra/sessions_controller"

describe "SessionsController" do
  describe "GET /login" do
    it "has a password input and login button" do
      get "/login"

      page = last_response.body
      expect(page).to have_tag("input#password")
    end
  end

  describe "POST /login" do
    it "denies access when password is incorrect" do
      create(:user)
      post "/login", password: "not-the-password"

      page = last_response.body
      expect(page).to have_tag(".error")
    end

    it "allows access when password is correct" do
      user = create(:user)

      post "/login", password: user.password

      expect(session[:user_id]).to eq(user.id)
    end

    it "redirects to the root page" do
      user = create(:user)

      post "/login", password: user.password

      expect(URI.parse(last_response.location).path).to eq("/")
    end

    it "redirects to the previous path when present" do
      user = create(:user)

      params = { password: user.password }
      post "/login", params, "rack.session" => { redirect_to: "/archive" }

      expect(URI.parse(last_response.location).path).to eq("/archive")
    end
  end

  describe "GET /logout" do
    it "clears the session" do
      get "/logout", {}, "rack.session" => { userid: 1 }

      expect(session[:user_id]).to be_nil
    end

    it "redirects to the root page" do
      get "/logout", {}, "rack.session" => { userid: 1 }

      expect(URI.parse(last_response.location).path).to eq("/")
    end
  end
end
