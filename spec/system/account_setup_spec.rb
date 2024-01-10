# frozen_string_literal: true

RSpec.describe "account setup" do
  def fill_in_fields(username:)
    fill_in("Username", with: username)
    fill_in("Password", with: "my-password")
    fill_in("Confirm", with: "my-password")
    click_on("Next")
  end

  it "allows a user to sign up" do
    visit "/"

    fill_in_fields(username: "my-username")

    expect(page).to have_text("Logged in as my-username")
  end

  it "allows a second user to sign up" do
    Setting::UserSignup.create!(enabled: true)
    create(:user)

    visit "/"

    expect(page).to have_link("sign up")
  end

  it "does not allow a second user to signup when not enabled" do
    create(:user)

    visit "/"

    expect(page).to have_no_link("sign up")
  end
end
