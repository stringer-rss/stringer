# frozen_string_literal: true

class Components::SingleFeedActionBar < Components::Base
  ROW_DATA = {
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

  attr_accessor :feed, :stories

  def initialize(feed:, stories:)
    super()
    self.feed = feed
    self.stories = stories
  end

  def view_template
    div(class: "row", data: ROW_DATA) do
      div(class: "float-start") { left_buttons }
      div(class: "float-end") do
        PRIMARY_BUTTONS.each { |button| primary_button(**button) }
      end
    end
  end

  private

  def left_buttons
    home_button
    whitespace
    mark_all_button
    whitespace
    refresh_button
  end

  def home_button
    title = t("partials.feed_action_bar.home")
    a(class: "btn", id: "home", href: "/news", title:) do
      i(class: "fa fa-reply")
    end
  end

  def mark_all_button
    title = t("partials.action_bar.mark_all")
    data = { action: "click->mark-all-as-read#submit", **hotkey("A") }
    a(class: "btn", id: "mark-all", title:, data:) do
      i(class: "fa fa-check")
      render(Components::MarkAllAsReadForm.new(stories:))
    end
  end

  def refresh_button
    title = t("partials.action_bar.refresh")
    href = "/feed/#{feed.id}"
    a(class: "btn", id: "refresh", href:, title:, data: hotkey("r")) do
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
