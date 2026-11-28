# frozen_string_literal: true

RSpec.describe Components::StoryKeepUnread do
  def render_form(story)
    html =
      ApplicationController.render(described_class.new(story:), layout: false)
    Capybara.string(html).find("form")
  end

  it "patches the story's keep unread path" do
    story = create(:story)

    expect(render_form(story)[:action])
      .to eq("/stories/#{story.id}/keep_unread")
  end

  it "has an id the Turbo Stream response can replace" do
    story = create(:story)

    expect(render_form(story)[:id]).to eq("story_#{story.id}_keep_unread")
  end

  it "carries the saved read state for the story controller" do
    form = render_form(create(:story, :read))

    expect(form["data-story-target"]).to eq("readState")
  end

  it "records whether the story is read and kept unread" do
    form = render_form(create(:story, keep_unread: true))

    expect([form["data-is-read"], form["data-keep-unread"]])
      .to eq(["false", "true"])
  end

  it "asks to keep a story unread when it isn't yet" do
    expect(render_form(create(:story)))
      .to have_field(name: "keep_unread", type: :hidden, with: "true")
  end

  it "asks to stop keeping a story unread when it is" do
    expect(render_form(create(:story, keep_unread: true)))
      .to have_field(name: "keep_unread", type: :hidden, with: "false")
  end

  it "shows a check when the story is kept unread" do
    expect(render_form(create(:story, keep_unread: true)))
      .to have_css("button.story-keep-unread .fa-check")
  end

  it "answers the m hotkey" do
    button = render_form(create(:story)).find("button")

    expect([button["data-hotkey"], button["data-hotkeys-target"]])
      .to eq(["m", "click"])
  end
end
