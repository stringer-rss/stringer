# frozen_string_literal: true

RSpec.describe "account setup" do
  def fill_in_fields
    fill_in("Username", with: "my-username")
    fill_in("Password", with: "my-password")
    fill_in("Confirm", with: "my-password")
  end

  it "allows a user to sign up" do
    visit "/"

    fill_in_fields

    click_button("Next")
    expect(page).to have_text("Logged in as my-username")
  end
end
