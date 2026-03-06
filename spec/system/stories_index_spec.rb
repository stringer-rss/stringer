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

  def open_story_and_find_unread_icon(story_title)
    find(".story-preview", text: story_title).click
    find(".story-actions .story-keep-unread i")
  end

  it "changes the keep unread icon on toggle", :aggregate_failures do
    create(:story, title: "My Story")
    login_as(default_user)
    visit(news_path)

    icon = open_story_and_find_unread_icon("My Story")
    expect(icon[:class]).to include("fa-square-o")

    find(".story-actions .story-keep-unread").click
    expect(icon[:class]).to include("fa-check")
    expect(icon[:class]).not_to include("fa-square-o")

    find(".story-actions .story-keep-unread").click
    expect(icon[:class]).to include("fa-square-o")
  end

  it "persists keep unread state across page reload" do
    create(:story, title: "My Story")
    login_as(default_user)
    visit(news_path)

    find(".story-preview", text: "My Story").click
    find(".story-actions .story-keep-unread").click
    visit(news_path)

    icon = open_story_and_find_unread_icon("My Story")
    expect(icon[:class]).to include("fa-check")
  end

  it "displays a download link for stories with enclosures" do
    create(
      :story,
      title: "Podcast Episode",
      enclosure_url: "http://example.com/episode.mp3"
    )
    login_as(default_user)
    visit(news_path)

    find(".story-preview", text: "Podcast Episode").click

    expect(page).to have_link(href: "http://example.com/episode.mp3")
  end

  it "does not display a download link for stories without enclosures" do
    create(:story, title: "Regular Story")
    login_as(default_user)
    visit(news_path)

    find(".story-preview", text: "Regular Story").click

    expect(page).to have_no_css("a.story-enclosure")
  end

  it "marks a story as read when opened" do
    create(:story, title: "My Story")
    login_as(default_user)
    visit news_path

    find(".story-preview", text: "My Story").click
    expect(page).to have_css(".story.read")
  end

  it "displays stories in newest-first order by default" do
    create(:story, title: "Older Story", published: 2.days.ago)
    create(:story, title: "Newer Story", published: 1.day.ago)
    login_as(default_user)

    visit news_path

    titles = all(".story-title").map(&:text)
    expect(titles).to eq(["Newer Story", "Older Story"])
  end

  it "displays stories in oldest-first order when configured" do
    default_user.update!(stories_order: "asc")
    create(:story, title: "Older Story", published: 2.days.ago)
    create(:story, title: "Newer Story", published: 1.day.ago)
    login_as(default_user)

    visit news_path

    titles = all(".story-title").map(&:text)
    expect(titles).to eq(["Older Story", "Newer Story"])
  end

  it "shows the unread count in the page title" do
    create(:story, title: "My Story")
    login_as(default_user)

    visit news_path

    expect(page).to have_title("(1)")
  end

  it "allows viewing a story with hot keys" do
    create(:story, title: "My Story", body: "My Body")
    login_as(default_user)
    visit news_path

    send_keys("j")

    expect(page).to have_content("My Body")
  end
end
