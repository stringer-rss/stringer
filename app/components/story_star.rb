# frozen_string_literal: true

# A star toggle button for a story. Each story shows two: one in its preview
# row and one in its actions, which also answers the s hotkey.
class Components::StoryStar < Components::Base
  attr_accessor :story, :hotkey

  def initialize(story:, hotkey: nil)
    super()
    self.story = story
    self.hotkey = hotkey
  end

  def view_template
    div(class: "story-starred", data:) do
      icon = story.is_starred ? "fa-star" : "fa-star-o"
      i(class: "fa #{icon}", data: { star_toggle_target: "icon" })
    end
  end

  private

  def data
    data = { action: "click->star-toggle#toggle:stop" }
    return data unless hotkey

    { **data, hotkeys_target: "click", hotkey: }
  end
end
