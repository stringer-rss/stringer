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

  it "keeps a sample story in place when refreshed" do
    open_sample_story("Darin' Fireballs")

    find(".story-actions .story-refresh").click

    expect(page).to have_current_path(setup_tutorial_path)
      .and have_css("li.story.open", text: "Darin' Fireballs")
  end
end
