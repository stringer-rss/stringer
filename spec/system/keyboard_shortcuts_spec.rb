# frozen_string_literal: true

RSpec.describe "keyboard shortcuts" do
  after { visit(logout_path) }

  def create_stories_and_visit
    create(:story, title: "First Story", body: "First Body")
    create(:story, title: "Second Story", body: "Second Body")
    visit(news_path)
  end

  it "opens a story with j" do
    login_as(default_user)
    create_stories_and_visit

    send_keys("j")

    expect(page).to have_css("li.story.open")
  end

  it "navigates up with k" do
    login_as(default_user)
    create_stories_and_visit

    send_keys("j", "j", "k")

    expect(page).to have_css("li.story.open", count: 1)
  end

  it "moves cursor without opening with n" do
    login_as(default_user)
    create_stories_and_visit

    send_keys("n")

    expect(page).to have_css("li.story.cursor:not(.open)")
  end

  it "moves cursor without opening with p" do
    login_as(default_user)
    create_stories_and_visit
    send_keys("n", "n")

    send_keys("p")

    expect(page).to have_css("li.story.cursor:not(.open)")
  end

  it "toggles a story open and closed with o" do
    login_as(default_user)
    create_stories_and_visit
    send_keys("o")

    send_keys("o")

    expect(page).to have_no_css("li.story.open")
  end

  it "toggles a story open and closed with enter" do
    login_as(default_user)
    create_stories_and_visit
    send_keys(:enter)

    send_keys(:enter)

    expect(page).to have_no_css("li.story.open")
  end

  def create_story_and_visit(title:)
    create(:story, title:)
    visit(news_path)
  end

  it "stars the current story with s" do
    login_as(default_user)
    create_story_and_visit(title: "My Story")
    send_keys("j", "s")

    visit(starred_path)

    expect(page).to have_content("My Story")
  end

  def open_story_and_send(key)
    send_keys("j")
    find("li.story.cursor .story-keep-unread")
    send_keys(key)
  end

  it "toggles keep unread with m" do
    login_as(default_user)
    create_story_and_visit(title: "My Story")
    open_story_and_send("m")
    visit(news_path)

    expect(page).to have_content("My Story")
  end

  it "refreshes the page with r" do
    login_as(default_user)
    visit(news_path)
    create(:story, title: "My Story")

    send_keys("r")

    expect(page).to have_content("My Story")
  end

  it "marks all as read with A" do
    login_as(default_user)
    create_story_and_visit(title: "My Story")

    send_keys("A")

    expect(page).to have_content("You've reached RSS Zero")
  end

  it "navigates to feeds with f" do
    login_as(default_user)
    create_story_and_visit(title: "My Story")

    send_keys("f")

    expect(page).to have_current_path(feeds_path)
  end

  it "navigates to add feed with a" do
    login_as(default_user)
    create_story_and_visit(title: "My Story")

    send_keys("a")

    expect(page).to have_current_path(feeds_new_path)
  end

  it "opens the shortcuts modal with ?" do
    login_as(default_user)
    create_story_and_visit(title: "My Story")

    send_keys("?")

    expect(page).to have_css("#shortcuts.in", visible: :visible)
  end
end
