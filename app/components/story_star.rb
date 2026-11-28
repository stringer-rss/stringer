# frozen_string_literal: true

# A star button for a story. Each story shows two: one in its preview row and
# one in its actions, which also answers the s hotkey.
#
# The button submits a form; the response is a Turbo Stream that replaces both
# buttons (see `StoriesController#star`), so the icon only changes once
# the server has saved the star.
class Components::StoryStar < Components::Base
  PLACEMENTS = [:preview, :actions].freeze

  attr_accessor :story, :placement

  def self.dom_id(story, placement)
    "story_#{story.id}_star_#{placement}"
  end

  # Both of the story's star buttons, by id, for a Turbo Stream response.
  def self.replacements(story)
    PLACEMENTS.to_h do |placement|
      [dom_id(story, placement), new(story:, placement:)]
    end
  end

  def initialize(story:, placement:)
    super()
    self.story = story
    self.placement = placement
  end

  def view_template
    url = "/stories/#{story.id}/star"
    id = self.class.dom_id(story, placement)
    form_with(url:, method: :patch, class: "story-star-form", id:) do
      input(type: "hidden", name: "starred", value: (!story.is_starred).to_s)
      star_button
    end
  end

  private

  def star_button
    aria_label = t(story.is_starred ? "stories.unstar" : "stories.star")
    button(type: "submit", class: "story-starred", aria_label:, data:) do
      i(class: "fa #{story.is_starred ? 'fa-star' : 'fa-star-o'}")
    end
  end

  def data
    placement == :actions ? { hotkeys_target: "click", hotkey: "s" } : {}
  end
end
