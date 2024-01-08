# frozen_string_literal: true

RSpec.describe "admin/good_job" do
  it "displays the GoodJob dashboard" do
    login_as(create(:user, admin: true))
    a11y_skip = [
      "aria-required-children",
      "color-contrast",
      "landmark-unique",
      "landmark-one-main",
      "page-has-heading-one",
      "region"
    ]
    visit(good_job_path, a11y_skip:)

    expect(page).to have_link("Scheduled").and have_link("Queued")
  end
end
