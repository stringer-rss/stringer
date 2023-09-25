# frozen_string_literal: true

RSpec.describe SettingsController do
  describe "#index" do
    it "displays the settings page" do
      login_as(create(:user, admin: true))

      get(settings_path)

      expect(rendered).to have_css("h1", text: "Settings")
        .and have_text("User signups are disabled")
    end
  end

  describe "#update" do
    it "allows enabling account creation" do
      login_as(create(:user, admin: true))

      params = { setting: { enabled: "true" } }
      put(setting_path(Setting::UserSignup.first), params:)

      expect(Setting::UserSignup.enabled?).to be(true)
    end
  end
end
