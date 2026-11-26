# frozen_string_literal: true

RSpec.describe "account page" do
  def visit_account_page
    login_as(default_user)
    visit(account_path)
  end

  it "allows the user to edit their username" do
    visit_account_page
    fill_in_username_fields(default_user.password)
    click_on("Update username")

    expect(page).to have_text("Logged in as new_username")
  end

  def fill_in_username_fields(existing_password, username: "new_username")
    within_fieldset("Change username") do
      fill_in("Username", with: username)
      fill_in("Existing password", with: existing_password)
    end
  end

  it "allows the user to edit their password" do
    visit_account_page
    fill_in_password_fields(default_user.password, "new_password")
    click_on("Update password")

    expect(page).to have_text("Password updated")
  end

  def fill_in_password_fields(existing_password, new_password)
    within_fieldset("Change password") do
      fill_in("Existing password", with: existing_password)
      fill_in("New password", with: new_password)
      fill_in("Password confirmation", with: new_password)
    end
  end

  it "allows the user to edit their feed order" do
    visit_account_page
    select("Oldest first", from: "Stories feed order")
    click_on("Update")

    expect(default_user.reload).to be_stories_order_asc
  end

  it "reflects the current stories order in the dropdown" do
    default_user.update!(stories_order: "asc")
    visit_account_page

    expect(page).to have_select("Stories feed order", selected: "Oldest first")
  end

  it "allows the user to group stories by feed" do
    visit_account_page
    check("Group stories by feed")
    click_on("Update")

    expect(default_user.reload.group_stories).to be(true)
  end

  it "rejects username change with wrong password" do
    visit_account_page
    fill_in_username_fields("wrong_password")
    click_on("Update username")

    expect(page).to have_text("Unable to update account")
  end

  def fill_in_mismatched_password_fields(existing_password)
    within_fieldset("Change password") do
      fill_in("Existing password", with: existing_password)
      fill_in("New password", with: "new_password")
      fill_in("Password confirmation", with: "different_password")
    end
  end

  it "rejects password change with mismatched confirmation" do
    visit_account_page
    fill_in_mismatched_password_fields(default_user.password)
    click_on("Update password")

    expect(page).to have_text("Unable to update password")
  end

  it "rejects username change when already taken" do
    create(:user, username: "taken_name")
    visit_account_page
    fill_in_username_fields(default_user.password, username: "taken_name")
    click_on("Update username")

    expect(page).to have_text("Unable to update account")
  end

  it "rejects password change with wrong existing password" do
    visit_account_page
    fill_in_password_fields("wrong_password", "new_password")
    click_on("Update password")

    expect(page).to have_text("Unable to update password")
  end

  it "allows the user to delete their account" do
    visit_account_page
    click_on("Delete account")
    click_on("Permanently delete account")

    expect(page).to have_text("Your account has been deleted")
  end

  it "allows the user to cancel deleting their account" do
    visit_account_page
    click_on("Delete account")
    click_on("Cancel")

    expect(page).to have_css("h1", text: "Account")
  end
end
