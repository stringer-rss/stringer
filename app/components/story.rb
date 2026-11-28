# frozen_string_literal: true

# One story in the story list. The `li` carries the Stimulus controllers and
# state classes; its contents sit in a Turbo Frame so refreshing the story
# from its feed swaps them in place (see `Components::StoryFrame`).
class Components::Story < Components::Base
  # The star and refresh forms submit inside the story's frame: sample
  # stories skip them, and a failed refresh leaves the story as it was.
  ACTIONS = [
    "keep-unread-toggle:toggled->story#keepUnreadToggled",
    "submit->story#formSubmitted",
    "turbo:frame-missing->story#frameMissing"
  ].join(" ").freeze

  attr_accessor :story

  def initialize(story:)
    super()
    self.story = story
  end

  def view_template
    li(class: classes, data:) { render(Components::StoryFrame.new(story:)) }
  end

  private

  def classes
    ["story", ("read" if story.is_read), ("keepUnread" if story.keep_unread)]
  end

  def data
    {
      controller: "story keep-unread-toggle",
      action: ACTIONS,
      **values,
      story_list_target: "story",
      unread_count_target: "story"
    }
  end

  def values
    read_state = { is_read: story.is_read, keep_unread: story.keep_unread }
    {
      **controller_values("story", **read_state),
      **controller_values("keep_unread_toggle", **read_state)
    }
  end

  def controller_values(controller, **values)
    { id: story.id, **values }.to_h do |name, value|
      [:"#{controller}_#{name}_value", value.to_s]
    end
  end
end
