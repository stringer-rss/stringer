# frozen_string_literal: true

RSpec.describe "starred" do
  it "displays starred stories" do
    login_as(default_user)
    create(:story, :starred, title: "Fave Story")

    visit(starred_path)

    expect(page).to have_content("Fave Story")
  end

  it "shows a message when no stories are starred" do
    login_as(default_user)

    visit(starred_path)

    expect(page).to have_content("you haven't starred any stories")
  end

  def unstar_story(story_title)
    find(".story-preview", text: story_title).click
    find(".story-actions .story-starred").click
  end

  it "unstars a story from the starred view" do
    login_as(default_user)
    create(:story, :starred, title: "Starred Story")
    visit(starred_path)

    unstar_story("Starred Story")
    visit(starred_path)

    expect(page).to have_content("you haven't starred any stories")
  end

  def open_story_and_find_star_icon(story_title)
    find(".story-preview", text: story_title).click
    find(".story-actions .story-starred i")
  end

  it "changes the star icon on toggle", :aggregate_failures do
    login_as(default_user)
    create(:story, title: "My Story")
    visit(news_path)

    icon = open_story_and_find_star_icon("My Story")
    expect(icon[:class]).to include("fa-star-o")

    find(".story-actions .story-starred").click
    expect(icon[:class]).to include("fa-star")
    expect(icon[:class]).not_to include("fa-star-o")

    find(".story-actions .story-starred").click
    expect(icon[:class]).to include("fa-star-o")
  end

  it "stars from the preview row" do
    login_as(default_user)
    create(:story, title: "Preview Star Story")
    visit(news_path)

    find(".story-preview .story-starred", text: "").click
    visit(starred_path)

    expect(page).to have_content("Preview Star Story")
  end

  def create_starred_stories(count)
    count.times { create(:story, :starred) }
  end

  it "paginates starred stories" do
    login_as(default_user)
    create_starred_stories(21)

    visit(starred_path)

    expect(page).to have_link("Next")
  end
end
