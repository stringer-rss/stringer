# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

RSpec.describe PasswordsController, type: :controller do
  def setup
    expect(UserRepository).to receive(:setup_complete?).twice.and_return(false)
  end

  describe "#new" do
    it "displays a form to enter your password" do
      setup

      get "/setup/password"

      page = last_response.body
      expect(page).to have_tag("form#password_setup")
    end
  end

  describe "#create" do
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
      post "/setup/password", password: "foo", password_confirmation: "foo"

      expect(URI.parse(last_response.location).path).to eq("/feeds/import")
    end
  end
end
