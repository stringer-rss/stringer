# frozen_string_literal: true

RSpec.describe "application settings" do
  it "allows enabling account creation" do
    login_as(create(:user, admin: true))
    visit(settings_path)

    within("form", text: "User signups are disabled") { click_on("Enable") }

    expect(page).to have_content("User signups are enabled")
  end

  it "allows disabling account creation" do
    Setting::UserSignup.first.update!(enabled: true)
    login_as(create(:user, admin: true))
    visit(settings_path)

    within("form", text: "User signups are enabled") { click_on("Disable") }

    expect(page).to have_content("User signups are disabled")
  end

  it "blocks non-admin users from settings" do
    login_as(default_user)

    visit(settings_path)

    expect(page).to have_content("No route matches")
  end

  it "prevents signup when signups are disabled" do
    create(:user, admin: true)

    visit(setup_password_path)

    expect(page).to have_current_path(login_path)
  end
end
