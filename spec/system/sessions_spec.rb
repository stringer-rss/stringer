# frozen_string_literal: true

RSpec.describe "user sessions" do
  def user_params
    {
      email: "demo@lmkw.io",
      password: "secret",
      password_confirmation: "secret",
    }
  end

  def sign_in_with(email:, password:)
    visit("/")

    click_on("Log In")

    expect(page).to have_text("Log in to YourAppNameHere")

    fill_in("Email", with: email)
    fill_in("Password", with: password)

    click_on("Log In")
  end

  it "allows a user to log into their account" do
    user = User.create!(user_params)

    sign_in_with(email: user.email, password: user.password)

    expect(page).to have_text(user.email)
    expect(page).to have_link("Account")
    expect(page).to have_no_link("Log In")
  end

  it "allows a user to log out" do
    user = User.create!(user_params)

    sign_in_with(email: user.email, password: user.password)

    click_on("Log Out")

    expect(page).to have_link("Log In")
    expect(page).to have_no_text(user.email)
  end
end
