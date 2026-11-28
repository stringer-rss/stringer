# frozen_string_literal: true

RSpec.describe Components::StoryStar do
  def render_star(story, placement)
    html = ApplicationController.render(
      described_class.new(story:, placement:),
      layout: false
    )
    Capybara.string(html)
  end

  it "posts to the story's star path with an id for its placement" do
    story = create(:story)
    form = render_star(story, :preview).find("form")

    expect([form[:action], form[:id]])
      .to eq(["/stories/#{story.id}/star", "story_#{story.id}_star_preview"])
  end

  it "asks to star an unstarred story" do
    rendered = render_star(create(:story), :preview)

    expect(rendered).to have_field(name: "starred", type: :hidden, with: "true")
  end

  it "asks to unstar a starred story" do
    rendered = render_star(create(:story, :starred), :preview)

    expect(rendered)
      .to have_field(name: "starred", type: :hidden, with: "false")
  end

  it "shows a filled star for a starred story" do
    expect(render_star(create(:story, :starred), :preview))
      .to have_css("button.story-starred .fa-star")
  end

  it "labels the button with what it will do" do
    button = render_star(create(:story, :starred), :preview).find("button")

    expect(button["aria-label"]).to eq("Unstar")
  end

  it "answers the s hotkey from the actions row" do
    button = render_star(create(:story), :actions).find("button")

    expect([button["data-hotkey"], button["data-hotkeys-target"]])
      .to eq(["s", "click"])
  end

  it "leaves the preview row's star without a hotkey" do
    button = render_star(create(:story), :preview).find("button")

    expect(button["data-hotkey"]).to be_nil
  end
end
