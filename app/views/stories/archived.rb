# frozen_string_literal: true

class Views::Stories::Archived < Views::Base
  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def page_title = t("page_titles.archived_stories")

  def view_template
    div(id: "action-bar") { render(Components::FeedActionBar.new) }

    if stories.empty?
      div(id: "sorry") { p { t("archive.sorry") } }
    else
      render(Components::StoryList.new(stories:, title: site_title))
      render(Components::Pagination.new(stories:, scope: "archive"))
    end
  end
end
