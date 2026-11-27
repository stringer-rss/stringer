# frozen_string_literal: true

class Components::FeedActionBar < Components::Base
  def view_template
    nav do
      div { home_button }
      render(Components::LoggedInAs.new)
      div { primary_buttons }
    end
  end

  private

  def home_button
    title = t("partials.feed_action_bar.home")
    button("btn", "home", "/news", title, "fa-reply")
  end

  def primary_buttons
    title = t("partials.feed_action_bar.starred_stories")
    primary_button("starred", "/starred", title, "fa-star")
    title = t("partials.feed_action_bar.archived_stories")
    primary_button("archive", "/archive", title, "fa-clock-o")
    title = t("partials.feed_action_bar.feeds")
    primary_button("feeds", "/feeds", title, "fa-list")
    title = t("partials.feed_action_bar.add_feed")
    primary_button("add-feed", "/feeds/new", title, "fa-plus")
  end

  def primary_button(id, href, title, icon)
    whitespace
    button("btn btn-primary", id, href, title, icon)
  end

  def button(css_class, id, href, title, icon)
    a(class: css_class, id:, href:, title:) { i(class: "fa #{icon}") }
  end
end
