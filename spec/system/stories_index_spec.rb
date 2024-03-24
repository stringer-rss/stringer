# frozen_string_literal: true

RSpec.describe "stories/index" do
  it "displays the stories" do
    create(:story, title: "My Story")
    login_as(default_user)

    visit news_path

    expect(page).to have_content("My Story")
  end

  it "does not display read stories" do
    create(:story, :read, title: "My Story")
    login_as(default_user)

    visit news_path

    expect(page).to have_no_content("My Story")
  end

  it "marks all stories as read" do
    create(:story, title: "My Story")
    login_as(default_user)
    visit news_path

    click_on "Mark all as read"

    expect(page).to have_content("You've reached RSS Zero")
  end

  it "refreshes the page" do
    login_as(default_user)
    visit news_path
    create(:story, title: "My Story")

    click_on "Refresh"

    expect(page).to have_content("My Story")
  end

  it "displays the story body when the row is clicked" do
    create(:story, title: "My Story", body: "My Body")
    login_as(default_user)
    visit news_path

    find(".story-preview", text: "My Story").click

    expect(page).to have_content("My Body")
  end

  def star_story(story_title)
    visit(news_path)

    find(".story-preview", text: story_title).click
    find(".story-actions .story-starred").click
  end

  it "allows marking a story as starred" do
    create(:story, title: "My Story")
    login_as(default_user)

    star_story("My Story")

    visit(starred_path)
    expect(page).to have_content("My Story")
  end

  it "allows marking a story as unstarred" do
    create(:story, :starred, title: "My Story")
    login_as(default_user)

    star_story("My Story")

    visit(starred_path)
    expect(page).to have_no_content("My Story")
  end

  def mark_story_unread(story_title)
    visit(news_path)

    find(".story-preview", text: story_title).click
    find(".story-actions .story-keep-unread").click
  end

  it "allows marking a story as unread" do
    create(:story, :starred, title: "My Story")
    login_as(default_user)
    mark_story_unread("My Story")

    visit(news_path)

    expect(page).to have_content("My Story")
  end

  it "allows viewing a story with hot keys" do
    create(:story, title: "My Story", body: "My Body")
    login_as(default_user)
    visit news_path

    send_keys("j")

    expect(page).to have_content("My Body")
  end
end
