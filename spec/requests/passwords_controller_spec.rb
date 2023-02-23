# frozen_string_literal: true

RSpec.describe PasswordsController do
  def setup
    expect(UserRepository).to receive(:setup_complete?).and_return(false)
  end

  describe "#new" do
    it "displays a form to enter your password" do
      setup

      get "/setup/password"

      expect(rendered).to have_selector("form#password_setup")
    end

    it "redirects to the news path if setup is complete" do
      create(:user)

      get "/setup/password"

      expect(response).to redirect_to("/news")
    end
  end

  describe "#create" do
    it "rejects empty passwords" do
      setup

      post "/setup/password"

      expect(rendered).to have_selector("div.error")
    end

    it "rejects when password isn't confirmed" do
      setup

      post "/setup/password",
           params: { password: "foo", password_confirmation: "bar" }

      expect(rendered).to have_selector("div.error")
    end

    it "accepts confirmed passwords and redirects to next step" do
      post "/setup/password",
           params: { password: "foo", password_confirmation: "foo" }

      expect(URI.parse(response.location).path).to eq("/feeds/import")
    end
  end
end
