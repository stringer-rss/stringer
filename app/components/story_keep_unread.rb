# frozen_string_literal: true

# The keep unread button for a story, which also answers the m hotkey.
#
# The button submits a form; the response is a Turbo Stream that replaces
# this form with the saved state. The form is the story controller's
# `readState` target, so when it is replaced the controller copies the saved
# read and keep unread state onto the story.
class Components::StoryKeepUnread < Components::Base
  attr_accessor :story

  def self.dom_id(story)
    "story_#{story.id}_keep_unread"
  end

  # This button, by id, for a Turbo Stream response.
  def self.replacements(story)
    { dom_id(story) => new(story:) }
  end

  def initialize(story:)
    super()
    self.story = story
  end

  def view_template
    url = "/stories/#{story.id}/keep_unread"
    form_with(url:, method: :patch, class: "story-keep-unread-form", **attrs) do
      value = (!story.keep_unread).to_s
      input(type: "hidden", name: "keep_unread", value:)
      keep_unread_button
    end
  end

  private

  def attrs
    {
      id: self.class.dom_id(story),
      data: {
        story_target: "readState",
        is_read: story.is_read.to_s,
        keep_unread: story.keep_unread.to_s
      }
    }
  end

  def keep_unread_button
    data = { hotkeys_target: "click", hotkey: "m" }
    button(type: "submit", class: "story-keep-unread", data:) do
      i(class: "fa #{story.keep_unread ? 'fa-check' : 'fa-square-o'}")
      plain(" #{t('stories.keep_unread')}")
    end
  end
end
