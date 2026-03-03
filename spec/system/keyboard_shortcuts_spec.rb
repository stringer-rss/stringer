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
end
