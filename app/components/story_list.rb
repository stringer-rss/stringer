# frozen_string_literal: true

# The Backbone-rendered story list. The `stories/js` partial stays ERB until
# the Backbone removal replaces it with server-rendered stories.
#
# `title` is the page's browser title without an unread count. The
# unread-count controller puts the live count in front of it.
class Components::StoryList < Components::Base
  KEY_ACTIONS = {
    "j" => "openNext",
    "k" => "openPrevious",
    "n" => "next",
    "p" => "previous",
    "o" => "toggleCurrent",
    "enter" => "toggleCurrent"
  }.freeze

  # The b/v/m/s keys click buttons in the cursor story through the hotkeys
  # controller, scoped by `hotkeys_scope_value`.
  ACTIONS = [
    "story:read-changed->unread-count#update",
    "story:opened->story-list#storyOpened",
    "keydown@document->hotkeys#handleKeydown",
    *KEY_ACTIONS.map do |key, action|
      "keydown.#{key}@document->story-list##{action}"
    end
  ].join(" ").freeze

  attr_accessor :stories, :title

  def initialize(stories:, title:)
    super()
    self.stories = stories
    self.title = title
  end

  def view_template
    render(partial("stories/js", stories:))

    div(id: "stories", data: stories_data) { ul(id: "story-list") }
  end

  private

  def stories_data
    {
      controller: "unread-count story-list hotkeys",
      action: ACTIONS,
      hotkeys_scope_value: ".story.cursor",
      story_list_story_outlet: "#story-list > li.story",
      unread_count_title_value: title
    }
  end
end
