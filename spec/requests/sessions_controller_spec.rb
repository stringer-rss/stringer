# frozen_string_literal: true

RSpec.describe SessionsController do
  describe "#new" do
    it "has a password input and login button" do
      create(:user)

      get "/login"

      page = response.body
      expect(page).to have_tag("input#password")
    end
  end

  describe "#create" do
    it "denies access when password is incorrect" do
      create(:user)
      post "/login", params: { password: "not-the-password" }

      page = response.body
      expect(page).to have_tag(".error")
    end

    it "allows access when password is correct" do
      user = default_user

      post "/login", params: { password: user.password }

      expect(session[:user_id]).to eq(user.id)
    end

    it "redirects to the root page" do
      user = default_user

      post "/login", params: { password: user.password }

      expect(URI.parse(response.location).path).to eq("/")
    end

    it "redirects to the previous path when present" do
      user = default_user

      get("/archive")
      post("/login", params: { password: user.password })

      expect(URI.parse(response.location).path).to eq("/archive")
    end
  end

  describe "#destroy" do
    it "clears the session" do
      login_as(default_user)

      get "/logout"

      expect(session[:user_id]).to be_nil
    end

    it "redirects to the root page" do
      login_as(default_user)

      get "/logout"

      expect(URI.parse(response.location).path).to eq("/")
    end
  end
end
