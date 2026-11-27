# frozen_string_literal: true

class Views::Stories::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor

  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    content_for(:title, "(#{stories.count})") unless stories.empty?

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
