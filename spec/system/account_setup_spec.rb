# frozen_string_literal: true

RSpec.describe "account setup" do
  def fill_in_fields(username:, confirm: "my-password")
    fill_in("Username", with: username)
    fill_in("Password", with: "my-password")
    fill_in("Confirm", with: confirm)
    click_on("Next")
  end

  it "allows a user to sign up" do
    visit "/"

    fill_in_fields(username: "my-username")

    expect(page).to have_text("Logged in as my-username")
  end

  it "shows an error when passwords do not match" do
    visit "/"

    fill_in_fields(username: "my-username", confirm: "wrong-password")

    expect(page).to have_content("doesn't match")
  end

  it "allows a second user to sign up" do
    Setting::UserSignup.create!(enabled: true)
    create(:user)

    visit "/"

    expect(page).to have_link("sign up")
  end

  it "completes sign up for a second user" do
    Setting::UserSignup.create!(enabled: true)
    create(:user)
    visit(setup_password_path)

    fill_in_fields(username: "second-user")

    expect(page).to have_text("Logged in as second-user")
  end

  it "does not allow a second user to signup when not enabled" do
    create(:user)

    visit "/"

    expect(page).to have_no_link("sign up")
  end
end
