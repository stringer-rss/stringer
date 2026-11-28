# frozen_string_literal: true

# The row under an open story: its date, and buttons to keep it unread, star
# it, refresh it from its feed, and open its permalink. The keep unread, star
# and permalink buttons answer the m, s and b/v hotkeys for the cursor story.
class Components::StoryActions < Components::Base
  attr_accessor :story

  def initialize(story:)
    super()
    self.story = story
  end

  def view_template
    div(class: "story-actions-container") do
      div { span(class: "story-published") { story.pretty_date } }
      div(class: "story-actions") do
        keep_unread_button
        render(Components::StoryStar.new(story:, placement: :actions))
        refresh_button
        permalink_link
      end
    end
  end

  private

  def keep_unread_button
    data = { action: "click->keep-unread-toggle#toggle:stop", **hotkey("m") }
    div(class: "story-keep-unread", data:) do
      icon = story.keep_unread ? "fa-check" : "fa-square-o"
      i(class: "fa #{icon}", data: { keep_unread_toggle_target: "icon" })
      plain(" #{t('stories.keep_unread')}")
    end
  end

  # Submits inside the story's Turbo Frame; see Components::StoryFrame.
  def refresh_button
    url = "/stories/#{story.id}/refresh"
    form_with(url:, class: "story-refresh-form") do
      title = t("stories.refresh")
      button(type: "submit", class: "story-refresh", title:) do
        i(class: "fa fa-refresh")
      end
    end
  end

  def permalink_link
    data = { story_target: "permalink", **hotkey("b v") }
    href = story.permalink
    a(class: "story-permalink", target: "_blank", href:, data:) do
      i(class: "fa fa-external-link")
    end
  end

  def hotkey(keys)
    { hotkeys_target: "click", hotkey: keys }
  end
end
