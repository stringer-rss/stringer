# frozen_string_literal: true

RSpec.describe "JS tests" do
  it "passes the mocha tests" do
    login_as(default_user)

    visit "/test"

    expect(page).to have_content("failures: 0")
  end
end
