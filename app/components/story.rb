# frozen_string_literal: true

# One story in the story list. The `li` carries the Stimulus controllers and
# state classes; its contents sit in a Turbo Frame so refreshing the story
# from its feed swaps them in place (see `Components::StoryFrame`).
class Components::Story < Components::Base
  # A failed refresh leaves the story as it was.
  ACTIONS = "turbo:frame-missing->story#frameMissing"

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
      controller: "story",
      action: ACTIONS,
      **values,
      story_list_target: "story",
      unread_count_target: "story"
    }
  end

  def values
    {
      story_id_value: story.id.to_s,
      story_is_read_value: story.is_read.to_s,
      story_keep_unread_value: story.keep_unread.to_s
    }
  end
end
