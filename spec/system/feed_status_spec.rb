# frozen_string_literal: true

RSpec.describe "feed status bubbles" do
  it "shows a green status for a healthy feed" do
    login_as(default_user)
    create(:feed, status: :green)

    visit("/feeds")

    expect(page).to have_css(".status.green")
  end

  it "shows a red status for a feed that has never successfully fetched" do
    login_as(default_user)
    create(:feed, status: :red)

    visit("/feeds")

    expect(page).to have_css(".status.red")
  end

  it "shows a yellow status for a red feed that has stories" do
    login_as(default_user)
    feed = create(:feed, status: :red)
    create(:story, feed:)

    visit("/feeds")

    expect(page).to have_css(".status.yellow")
  end
end
