# frozen_string_literal: true

RSpec.describe "account setup" do
  def fill_in_fields(username:)
    fill_in("Username", with: username)
    fill_in("Password", with: "my-password")
    fill_in("Confirm", with: "my-password")
    click_button("Next")
  end

  it "allows a user to sign up" do
    visit "/"

    fill_in_fields(username: "my-username")

    expect(page).to have_text("Logged in as my-username")
  end

  it "allows a second user to sign up" do
    create(:user)
    visit "/"

    click_link("sign up")

    fill_in_fields(username: "my-username-2")

    expect(page).to have_text("Logged in as my-username-2")
  end
end
