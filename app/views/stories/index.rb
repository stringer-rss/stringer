# frozen_string_literal: true

class Views::Stories::Index < Views::Base
  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def page_title
    "(#{stories.count})" unless stories.empty?
  end

  def view_template
    div(id: "action-bar") do
      render(Components::StoriesActionBar.new(stories:))
    end

    if stories.empty?
      render(Components::Zen.new)
    else
      render(Components::StoryList.new(stories:))
    end
  end
end
