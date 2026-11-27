# frozen_string_literal: true

class Components::StoriesActionBar < Components::Base
  NAV_DATA = {
    controller: "hotkeys mark-all-as-read",
    action: "keydown@document->hotkeys#handleKeydown"
  }.freeze

  PRIMARY_BUTTONS = [
    {
      icon: "fa-star",
      id: "starred",
      href: "/starred",
      title: "partials.action_bar.starred_stories"
    },
    {
      icon: "fa-clock-o",
      id: "archive",
      href: "/archive",
      title: "partials.action_bar.archived_stories"
    },
    {
      icon: "fa-list",
      id: "feeds",
      href: "/feeds",
      hotkey: "f",
      title: "partials.action_bar.view_feeds"
    },
    {
      icon: "fa-plus",
      id: "add-feed",
      href: "/feeds/new",
      hotkey: "a",
      title: "partials.action_bar.add_feed"
    }
  ].freeze

  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    nav(data: NAV_DATA) do
      div do
        mark_all_button
        whitespace
        refresh_button
      end
      render(Components::LoggedInAs.new)
      div { PRIMARY_BUTTONS.each { |button| primary_button(**button) } }
    end
  end

  private

  def mark_all_button
    title = t("partials.action_bar.mark_all")
    data = { action: "click->mark-all-as-read#submit", **hotkey("A") }
    button(class: "btn", id: "mark-all", title:, aria_label: title, data:) do
      i(class: "fa fa-check")
      render(Components::MarkAllAsReadForm.new(stories:))
    end
  end

  def refresh_button
    title = t("partials.action_bar.refresh")
    a(class: "btn", href: "/", id: "refresh", title:, data: hotkey("r")) do
      i(class: "fa fa-refresh")
    end
  end

  def primary_button(icon:, title:, hotkey: nil, **attrs)
    whitespace
    data = hotkey ? hotkey(hotkey) : {}
    a(class: "btn btn-primary", title: t(title), data:, **attrs) do
      i(class: "fa #{icon}")
    end
  end

  def hotkey(key)
    { hotkeys_target: "click", hotkey: key }
  end
end
