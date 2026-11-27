# frozen_string_literal: true

class Components::MarkAllAsReadForm < Components::Base
  FORM_OPTIONS = {
    url: "/stories/mark_all_as_read",
    id: "mark-all-as-read",
    data: { "mark-all-as-read-target": "form" }
  }.freeze

  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    div(class: "d-none") do
      form_with(**FORM_OPTIONS) do
        stories.each do |story|
          input(type: "hidden", name: "story_ids[]", value: story.id)
        end
      end
    end
  end
end
