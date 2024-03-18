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

  def fill_in_username_fields(existing_password)
    within_fieldset("Change Username") do
      fill_in("Username", with: "new_username")
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
end
