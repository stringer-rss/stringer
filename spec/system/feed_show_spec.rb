# frozen_string_literal: true

RSpec.describe "feeds/show" do
  def create_and_visit_feed(story_title: nil)
    feed = create(:feed)
    create(:story, feed:, title: story_title) if story_title
    visit("/feed/#{feed.id}")
    feed
  end

  it "displays the feed name" do
    login_as(default_user)

    feed = create_and_visit_feed

    expect(page).to have_content(feed.name)
  end

  it "displays stories for the feed" do
    login_as(default_user)

    create_and_visit_feed(story_title: "My Story")

    expect(page).to have_content("My Story")
  end

  it "marks all stories as read" do
    login_as(default_user)
    create_and_visit_feed(story_title: "My Story")

    find_by_id("mark-all").click

    expect(page).to have_content("You've reached RSS Zero")
  end
end
