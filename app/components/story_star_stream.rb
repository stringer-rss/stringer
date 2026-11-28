# frozen_string_literal: true

# The response to starring or unstarring a story: a Turbo Stream that
# replaces both of the story's star buttons with their updated state.
class Components::StoryStarStream < Components::Base
  register_element :turbo_stream

  attr_accessor :story

  def initialize(story:)
    super()
    self.story = story
  end

  def view_template
    Components::StoryStar::PLACEMENTS.each do |placement|
      target = Components::StoryStar.dom_id(story, placement)
      turbo_stream(action: "replace", target:) do
        template { render(Components::StoryStar.new(story:, placement:)) }
      end
    end
  end
end
