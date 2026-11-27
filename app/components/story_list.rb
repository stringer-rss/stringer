# frozen_string_literal: true

# The Backbone-rendered story list. The `stories/js` partial stays ERB until
# the Backbone removal replaces it with server-rendered stories.
#
# `title` is the page's browser title without an unread count. The
# unread-count controller puts the live count in front of it.
class Components::StoryList < Components::Base
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
        controller: "unread-count",
        action: "story:read-changed->unread-count#update",
        unread_count_title_value: title
      }
    ) { ul(id: "story-list") }
  end
end
