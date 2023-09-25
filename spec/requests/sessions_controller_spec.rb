# frozen_string_literal: true

RSpec.describe SessionsController do
  describe "#new" do
    it "has a password input and login button" do
      create(:user)

      get "/login"

      expect(rendered).to have_field("password")
    end
  end

  describe "#create" do
    it "denies access when password is incorrect" do
      user = create(:user)
      params = { username: user.username, password: "not-the-password" }

      post("/login", params:)

      expect(rendered).to have_css(".error")
    end

    it "allows access when password is correct" do
      user = default_user
      params = { username: user.username, password: user.password }

      post("/login", params:)

      expect(session[:user_id]).to eq(user.id)
    end

    it "redirects to the root page" do
      user = default_user
      params = { username: user.username, password: user.password }

      post("/login", params:)

      expect(URI.parse(response.location).path).to eq("/")
    end

    it "redirects to the previous path when present" do
      user = default_user
      params = { username: user.username, password: user.password }
      get("/archive")

      post("/login", params:)

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
