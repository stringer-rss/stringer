# frozen_string_literal: true

# The Backbone-rendered story list. The `stories/js` partial stays ERB until
# the Backbone removal replaces it with server-rendered stories.
class Components::StoryList < Components::Base
  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    render(partial("stories/js", stories:))

    div(
      id: "stories",
      data: {
        controller: "unread-count",
        action: "story:read-changed->unread-count#update",
        unread_count_title_value: t("layout.title")
      }
    ) { ul(id: "story-list") }
  end
end
