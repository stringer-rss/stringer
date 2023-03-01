# frozen_string_literal: true

RSpec.describe "profile page" do
  it "allows the user to edit their username" do
    login_as(default_user)
    visit(edit_profile_path)

    fill_in("Username", with: "new_username")
    click_on("Save")

    expect(page).to have_text("Logged in as new_username")
  end

  it "allows the user to edit their password" do
    login_as(default_user)
    visit(edit_profile_path)

    fill_in_password_fields(default_user.password, "new_password")
    click_on("Update password")

    expect(page).to have_text("Password updated")
  end

  def fill_in_password_fields(existing_password, new_password)
    fill_in("Existing password", with: existing_password)
    fill_in("New password", with: new_password)
    fill_in("Password confirmation", with: new_password)
  end

  it "allows the user to regenerate their API key" do
    login_as(default_user)
    visit(edit_profile_path)

    click_on("Regenerate API key")

    expect(page).to have_text("API key regenerated")
      .and have_field("API key", with: default_user.reload.api_key)
  end
end
