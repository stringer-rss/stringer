# frozen_string_literal: true

RSpec.describe "login" do
  def submit_login(username:, password:)
    visit("/")
    fill_in("Username", with: username)
    fill_in("Password", with: password)
    click_on("Login")
  end

  it "allows a user to log in" do
    user = create(:user)

    submit_login(username: user.username, password: user.password)

    expect(page).to have_content("Logged in as #{user.username}")
  end

  it "shows an error for wrong password" do
    user = create(:user)

    submit_login(username: user.username, password: "wrong-password")

    expect(page).to have_content("That's the wrong password")
  end

  def login_from_current_page(user)
    fill_in("Username", with: user.username)
    fill_in("Password", with: user.password)
    click_on("Login")
  end

  it "redirects to the original page after login" do
    user = create(:user)
    visit(starred_path)

    login_from_current_page(user)

    expect(page).to have_current_path(starred_path)
  end

  it "allows a user to log out" do
    login_as(default_user)

    click_on("Logout")

    expect(page).to have_content("You have been signed out!")
  end
end
