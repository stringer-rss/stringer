# frozen_string_literal: true

RSpec.describe Components::Story do
  def render_story(story)
    html =
      ApplicationController.render(described_class.new(story:), layout: false)
    Capybara.string(html)
  end

  def story_li(story)
    render_story(story).find("li.story")
  end

  it "sets the Stimulus controllers on the li" do
    li = story_li(create(:story))

    expect(li["data-controller"]).to eq("story")
  end

  def values(element)
    names = ["story-id", "story-is-read", "story-keep-unread"]
    names.map { |name| element["data-#{name}-value"] }
  end

  it "sets the Stimulus values on the li" do
    story = create(:story, keep_unread: true)

    expect(values(story_li(story))).to eq([story.id.to_s, "false", "true"])
  end

  it "keeps the story in place when a refresh fails" do
    li = story_li(create(:story))

    expect(li["data-action"]).to eq("turbo:frame-missing->story#frameMissing")
  end

  it "makes the li a story-list and unread-count target", :aggregate_failures do
    li = story_li(create(:story))

    expect(li["data-story-list-target"]).to eq("story")
    expect(li["data-unread-count-target"]).to eq("story")
  end

  it "adds the read and keepUnread classes from the story's state" do
    li = story_li(create(:story, :read, keep_unread: true))

    expect(li[:class]).to eq("story read keepUnread")
  end

  it "leaves off the state classes for an unread story" do
    expect(story_li(create(:story))[:class]).to eq("story")
  end

  it "wraps the contents in a Turbo Frame for the story" do
    story = create(:story)

    expect(render_story(story))
      .to have_css("li > turbo-frame#story_#{story.id}")
  end

  it "escapes the headline" do
    story = create(:story, title: "&lt;b&gt;Bold&lt;/b&gt; &amp; more")

    expect(render_story(story)).to have_no_css(".story-details b")
      .and have_css(".story-title", text: "<b>Bold</b> & more")
  end

  it "escapes the lead" do
    story = create(:story, body: "&lt;i&gt;x&lt;/i&gt;")

    expect(render_story(story)).to have_no_css(".story-details i")
      .and have_css(".story-lead", text: "<i>x</i>")
  end

  it "renders the stored title and body as HTML" do
    story = create(:story, title: "<em>Title</em>", body: "<p>Body text</p>")

    expect(render_story(story))
      .to have_css(".story-body h1 a em", text: "Title")
      .and have_css(".story-body p", text: "Body text")
  end

  it "keeps feed markup beyond Rails' default allowlist" do
    body = "<table><tr><td>Cell</td></tr></table><video src='v.mp4'></video>"

    expect(render_story(create(:story, body:)))
      .to have_css(".story-content table td", text: "Cell")
      .and have_css(".story-content video[src='v.mp4']", visible: :all)
  end

  it "strips scripts from the body when rendering" do
    body = "<p>Text</p><script>alert(1)</script>"

    expect(render_story(create(:story, body:)))
      .to have_no_css(".story-content script", visible: :all)
  end

  it "links to the permalink as the b and v hotkey target" do
    story = create(:story, permalink: "https://example.com/post")
    link = render_story(story).find("a.story-permalink")

    expect([link[:href], link["data-hotkey"], link["data-story-target"]])
      .to eq(["https://example.com/post", "b v", "permalink"])
  end

  it "gives the keep unread button the m hotkey" do
    button = render_story(create(:story)).find(".story-keep-unread")

    expect(button["data-hotkey"]).to eq("m")
  end

  it "gives the action bar star button the s hotkey" do
    button = render_story(create(:story)).find(".story-actions .story-starred")

    expect(button["data-hotkey"]).to eq("s")
  end

  it "shows a download link when there is an enclosure" do
    story = create(:story, enclosure_url: "https://example.com/a.mp3")

    expect(render_story(story)).to have_link(href: "https://example.com/a.mp3")
  end

  it "shows no download link without an enclosure" do
    expect(render_story(create(:story))).to have_no_css(".story-enclosure")
  end

  it "fills in the star and keep unread icons from the story" do
    story = create(:story, is_starred: true, keep_unread: true)

    expect(render_story(story))
      .to have_css(".story-starred .fa-star", count: 2)
      .and have_css(".story-keep-unread .fa-check")
  end

  it "shows empty star and keep unread icons by default" do
    expect(render_story(create(:story)))
      .to have_css(".story-starred .fa-star-o", count: 2)
      .and have_css(".story-keep-unread .fa-square-o")
  end

  it "posts the refresh form to the story's refresh path" do
    story = create(:story)
    form = render_story(story).find("form:has(button.story-refresh)")

    expect(form[:action]).to eq("/stories/#{story.id}/refresh")
  end

  # Midday UTC is the same date in the machine's local zone, which
  # SampleStory uses.
  it "renders tutorial sample stories" do
    travel_to(Time.utc(2026, 6, 15, 12))
    sample = SampleStory.new("Feed Name", "Sample title")

    expect(render_story(sample))
      .to have_css("turbo-frame#story_#{sample.id}")
      .and have_css(".story-published", text: "Monday, June 15")
  end
end
