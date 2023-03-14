# frozen_string_literal: true

RSpec.describe "admin/good_job" do
  it "displays the GoodJob dashboard" do
    login_as(create(:user, admin: true))

    visit good_job_path

    expect(page).to have_link("Scheduled").and have_link("Queued")
  end
end
