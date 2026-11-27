# frozen_string_literal: true

class Views::Tutorials::Index < Views::Base
  # How long the tutorial-start controller waits before showing the start
  # button, giving the first feeds a chance to fetch.
  START_DELAY_MS = 10_000

  # Hidden until the tutorial-start controller shows it.
  START_BUTTON = {
    href: "/news",
    id: "start",
    style: "display: none",
    class: "btn btn-primary",
    data: { tutorial_start_target: "start" }
  }.freeze

  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def page_title = t("page_titles.tutorial")

  def view_template
    instructions

    div(id: "action-bar") do
      render(Components::TutorialActionBar.new(stories:))
    end

    render(Components::StoryList.new(stories:, title: site_title))
    setup
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
    div(class: "setup", data: start_data) do
      heading
      hr
      p(id: "cta", data: { tutorial_start_target: "cta" }) do
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

  def start_data
    {
      controller: "tutorial-start",
      tutorial_start_delay_value: START_DELAY_MS,
      tutorial_start_ready_value: t("tutorial.ready")
    }
  end
end
