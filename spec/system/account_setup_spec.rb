# frozen_string_literal: true

RSpec.describe "account setup" do
  it "allows a user to sign up" do
    visit "/"

    fill_in("Password", with: "my-password")
    fill_in("Confirm", with: "my-password")

    click_button("Next")
    expect(page).to have_content("Welcome aboard.")
  end
end
