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

  it "removes stories from news when a feed is deleted" do
    login_as(default_user)
    feed = create(:feed)
    create(:story, feed: feed, title: "Gone Story")
    visit("/feeds")

    click_on "Delete"
    visit(news_path)

    expect(page).to have_content("You've reached RSS Zero")
  end

  it "allows the user to edit a feed" do
    login_as(default_user)
    feed = create(:feed)

    visit "/feeds"
    click_on "Edit"

    expect(page).to have_field("Feed Name", with: feed.name)
  end

  it "displays the unread count for a feed" do
    login_as(default_user)
    feed = create(:feed)
    create_pair(:story, feed:)

    visit "/feeds"

    expect(page).to have_css(".feed-unread", text: "(2)")
  end

  it "displays last fetched as Never for new feeds" do
    login_as(default_user)
    create(:feed)

    visit "/feeds"

    expect(page).to have_content("Never")
  end

  it "displays the last fetched timestamp" do
    login_as(default_user)
    create(:feed, last_fetched: Time.zone.local(2024, 6, 15, 10, 30))

    visit "/feeds"

    expect(page).to have_content("Jun 15, 10:30")
  end

  it "links to the feed" do
    login_as(default_user)
    feed = create(:feed)

    visit "/feeds"

    expect(page).to have_link(href: feed.url)
  end
end
