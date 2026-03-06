# frozen_string_literal: true

RSpec.describe "profile page" do
  before do
    login_as(default_user)
    visit(edit_profile_path)
  end

  it "allows the user to edit their username" do
    fill_in_username_fields(default_user.password)
    click_on("Update username")

    expect(page).to have_text("Logged in as new_username")
  end

  def fill_in_username_fields(existing_password, username: "new_username")
    within_fieldset("Change Username") do
      fill_in("Username", with: username)
      fill_in("Existing password", with: existing_password)
    end
  end

  it "allows the user to edit their password" do
    fill_in_password_fields(default_user.password, "new_password")
    click_on("Update password")

    expect(page).to have_text("Password updated")
  end

  def fill_in_password_fields(existing_password, new_password)
    within_fieldset("Change Password") do
      fill_in("Existing password", with: existing_password)
      fill_in("New password", with: new_password)
      fill_in("Password confirmation", with: new_password)
    end
  end

  it "allows the user to edit their feed order" do
    select("Oldest first", from: "Stories feed order")
    click_on("Update")

    expect(default_user.reload).to be_stories_order_asc
  end

  it "reflects the current stories order in the dropdown" do
    default_user.update!(stories_order: "asc")
    visit(edit_profile_path)

    expect(page).to have_select("Stories feed order", selected: "Oldest first")
  end

  it "rejects username change with wrong password" do
    fill_in_username_fields("wrong_password")
    click_on("Update username")

    expect(page).to have_text("Unable to update profile")
  end

  def fill_in_mismatched_password_fields(existing_password)
    within_fieldset("Change Password") do
      fill_in("Existing password", with: existing_password)
      fill_in("New password", with: "new_password")
      fill_in("Password confirmation", with: "different_password")
    end
  end

  it "rejects password change with mismatched confirmation" do
    fill_in_mismatched_password_fields(default_user.password)
    click_on("Update password")

    expect(page).to have_text("Unable to update password")
  end

  it "rejects username change when already taken" do
    create(:user, username: "taken_name")
    fill_in_username_fields(default_user.password, username: "taken_name")
    click_on("Update username")

    expect(page).to have_text("Unable to update profile")
  end

  it "rejects password change with wrong existing password" do
    fill_in_password_fields("wrong_password", "new_password")
    click_on("Update password")

    expect(page).to have_text("Unable to update password")
  end
end
