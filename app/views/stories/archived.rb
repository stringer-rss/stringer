# frozen_string_literal: true

class Views::Stories::Archived < Views::Base
  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    div(id: "action-bar") { render(Components::FeedActionBar.new) }

    if stories.empty?
      div(id: "sorry") { p { t("archive.sorry") } }
    else
      render(Components::StoryList.new(stories:))
      render(Components::Pagination.new(stories:, scope: "archive"))
    end
  end
end
