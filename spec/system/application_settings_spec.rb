# frozen_string_literal: true

RSpec.describe "application settings" do
  it "allows enabling account creation" do
    login_as(create(:user, admin: true))
    visit(settings_path)

    within("form", text: "User signups are disabled") { click_on("Enable") }

    expect(page).to have_content("User signups are enabled")
  end
end
