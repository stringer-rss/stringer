# frozen_string_literal: true

RSpec.describe "user account" do
  def sign_up_with(
    email: "demo@lmkw.io",
    password: "secret",
    password_confirmation: password
  )
    visit("/")
    click_on("Sign Up")
    fill_in("Email", with: email)
    fill_in("Password", with: password)
    fill_in("Password confirmation", with: password_confirmation)
    click_on("Create Account")
  end

  def update_account_with(email:)
    click_on("Account")
    fill_in("Email", with: email)

    click_on("Update Account")
  end

  def delete_account
    click_on("Account")

    # accept_confirm("Are you sure? This cannot be undone.") do
    click_on("Delete Account")
    # end
  end

  it "allows a user to sign up for an account" do
    sign_up_with(email: "demo@lmkw.io")

    expect(page).to have_flash(:success, "Account created")
    expect(page).to have_text("demo@lmkw.io")
  end

  it "allows a user to edit their email" do
    sign_up_with(email: "demo@lmkw.io")
    update_account_with(email: "demo2@lmkw.io")

    expect(page).to have_text("demo2@lmkw.io")
  end

  it "allows a user to delete their account" do
    sign_up_with(email: "demo@lmkw.io")

    delete_account

    expect(page).to have_flash(:success, "Account permanently deleted")
    expect(page).to have_no_text("demo@lmkw.io")
  end
end
