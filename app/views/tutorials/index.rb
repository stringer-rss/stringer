# frozen_string_literal: true

class Views::Tutorials::Index < Views::Base
  # Swaps in the "ready" text and shows the start button once the first
  # feeds have had a chance to fetch.
  START_SCRIPT = <<~JS
    document.addEventListener("DOMContentLoaded", () => {
      setTimeout(() => {
        const cta   = document.getElementById("cta");
        const start = document.getElementById("start");

        cta.textContent = cta.dataset.ready;
        start.style.display = "";
      }, 10 * 1000);
    });
  JS

  # Hidden until START_SCRIPT shows it.
  START_BUTTON = {
    href: "/news",
    id: "start",
    style: "display: none",
    class: "btn btn-primary"
  }.freeze

  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    instructions

    div(id: "action-bar") do
      render(Components::TutorialActionBar.new(stories:))
    end

    render(Components::StoryList.new(stories:))
    setup

    script(type: "text/javascript") { raw(safe(START_SCRIPT)) }
  end

  private

  def instructions
    overlay("mark-all-instruction") do
      two_lines("#{t('tutorial.mark_all')} ", t("tutorial.as_read"))
    end
    overlay("refresh-instruction") { t("tutorial.refresh") }
    overlay("feeds-instruction") { t("tutorial.your_feeds") }
    overlay("add-feed-instruction") { t("tutorial.add_feed") }
    overlay("story-instruction") do
      two_lines(t("tutorial.your_stories"), t("tutorial.click_to_read"))
    end
  end

  def overlay(id, &)
    div(class: "tutorial-overlay") { p(class: "instruction", id:, &) }
  end

  def two_lines(first, second)
    plain(first)
    br
    plain(second)
  end

  def setup
    div(class: "setup") do
      heading
      hr
      p(id: "cta", data: { ready: t("tutorial.ready") }) do
        t("tutorial.description")
      end
      hr
      div(class: "center") { start_button }
    end
  end

  def heading
    h1 do
      plain("#{t('tutorial.title')} ")
      span(class: "orange") { t("tutorial.simple") }
      plain(".")
    end
    h2 { t("tutorial.subtitle") }
  end

  def start_button
    a(**START_BUTTON) { t("tutorial.start") }
  end
end
