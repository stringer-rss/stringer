# frozen_string_literal: true

RSpec.describe "tutorial" do
  around { |example| with_test_adapter(&example) }

  it "displays the tutorial page" do
    login_as(default_user)

    visit(setup_tutorial_path)

    expect(page).to have_text("Stringer is simple")
    expect(CallableJob).to have_been_enqueued
  end

  it "displays sample stories" do
    login_as(default_user)

    visit(setup_tutorial_path)

    expect(page).to have_text("Darin' Fireballs")
  end

  def open_sample_story(source)
    login_as(default_user)
    visit(setup_tutorial_path)
    find(".story-preview", text: source).click
  end

  it "pretends to refresh a sample story" do
    open_sample_story("Darin' Fireballs")

    find(".story-actions .story-refresh").click

    expect(page).to have_css("li.story.open [aria-busy='true'] .fa-refresh")
      .and have_current_path(setup_tutorial_path)
  end

  it "stars a sample story without saving it" do
    open_sample_story("Darin' Fireballs")

    find(".story-actions .story-starred").click

    expect(page).to have_css("li.story.open .story-starred .fa-star", count: 2)
  end

  it "keeps a sample story unread without saving it" do
    open_sample_story("Darin' Fireballs")

    find(".story-actions .story-keep-unread").click

    expect(page).to have_css("li.story.open.keepUnread .fa-check")
  end
end
