# frozen_string_literal: true

# Previous/next links for a paginated story list. `scope` is the locale scope
# holding the `previous`, `of` and `next` labels.
class Components::Pagination < Components::Base
  HOTKEYS = {
    controller: "hotkeys",
    action: "keydown@document->hotkeys#handleKeydown"
  }.freeze

  attr_accessor :stories, :scope

  def initialize(stories:, scope:)
    super()
    self.stories = stories
    self.scope = scope
  end

  def view_template
    div(id: "pagination", data: HOTKEYS) do
      previous_link
      page_count
      next_link
    end
  end

  private

  def previous_link
    return unless stories.previous_page

    page_link("prev_page", stories.previous_page, "ArrowLeft", :previous)
    whitespace
  end

  def page_count
    return if stories.total_pages <= 1

    of = t(:of, scope:)
    plain("#{stories.current_page} #{of} #{stories.total_pages}")
    whitespace
  end

  def next_link
    return unless stories.next_page

    page_link("next_page", stories.next_page, "ArrowRight", :next)
  end

  def page_link(id, page, hotkey, label_key)
    a(
      id:,
      href: "?page=#{page}",
      data: { hotkeys_target: "click", hotkey: }
    ) { t(label_key, scope:) }
  end
end
