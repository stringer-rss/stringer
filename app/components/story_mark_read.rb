# frozen_string_literal: true

# A form with no visible fields that the story controller submits when the
# story opens. The response is a Turbo Stream that replaces the keep unread
# form, whose saved state then marks the story read (see
# `Components::StoryKeepUnread`).
class Components::StoryMarkRead < Components::Base
  attr_accessor :story

  def initialize(story:)
    super()
    self.story = story
  end

  # The empty block matters: without one, form_with leaves the form open.
  def view_template
    form_with(
      url: "/stories/#{story.id}/read",
      method: :patch,
      class: "story-mark-read-form",
      data: { story_target: "markRead" }
    ) { nil }
  end
end
