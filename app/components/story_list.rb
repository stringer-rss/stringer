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
    "enter" => "toggleCurrent",
    "b" => "openCurrentInTab",
    "v" => "openCurrentInTab"
  }.freeze

  ACTIONS = [
    "story:read-changed->unread-count#update",
    "story:opened->story-list#storyOpened",
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

    div(
      id: "stories",
      data: {
        controller: "unread-count story-list",
        action: ACTIONS,
        story_list_story_outlet: "#story-list > li.story",
        unread_count_title_value: title
      }
    ) { ul(id: "story-list") }
  end
end
