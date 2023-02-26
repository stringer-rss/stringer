# frozen_string_literal: true

RSpec.describe "profile page" do
  it "allows the user to edit their username" do
    login_as(default_user)
    visit(edit_profile_path)

    fill_in("Username", with: "new_username")
    click_on("Save")

    expect(page).to have_text("Logged in as new_username")
  end
end
