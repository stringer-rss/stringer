# frozen_string_literal: true

RSpec.describe "feeds/index" do
  it "displays a list of feeds" do
    login_as(default_user)
    create_pair(:feed)

    visit "/feeds"

    expect(page).to have_css("li.feed", count: 2)
  end

  it "displays message to add feeds if there are none" do
    login_as(default_user)

    visit "/feeds"

    expect(page).to have_content("Hey, you should add some feeds")
  end

  it "allows the user to delete a feed" do
    login_as(default_user)
    create(:feed)

    visit("/feeds")
    click_on "Delete"

    expect(page).to have_content("Feed deleted")
  end

  it "allows the user to edit a feed" do
    login_as(default_user)
    feed = create(:feed)

    visit "/feeds"
    click_on "Edit"

    expect(page).to have_field("Feed Name", with: feed.name)
  end

  it "links to the feed" do
    login_as(default_user)
    feed = create(:feed)

    visit "/feeds"

    expect(page).to have_link(href: feed.url)
  end
end
