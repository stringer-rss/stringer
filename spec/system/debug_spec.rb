# frozen_string_literal: true

RSpec.describe "admin/debug" do
  it "displays debug information" do
    login_as(create(:user, admin: true))

    visit("/admin/debug")

    expect(page).to have_text(RUBY_VERSION)
  end

  it "shows None when there are no pending migrations" do
    login_as(create(:user, admin: true))

    visit("/admin/debug")

    expect(page).to have_text("None")
  end

  it "shows the queued jobs count" do
    login_as(create(:user, admin: true))

    visit("/admin/debug")

    expect(page).to have_text("Queued Jobs")
  end

  it "blocks non-admin users" do
    login_as(default_user)

    visit("/admin/debug")

    expect(page).to have_text("No route matches")
  end
end
