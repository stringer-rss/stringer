# frozen_string_literal: true

class Components::TutorialActionBar < Components::Base
  attr_accessor :stories

  def initialize(stories:)
    super()
    self.stories = stories
  end

  def view_template
    nav do
      div { left_buttons }
      render(Components::LoggedInAs.new)
      div { right_buttons }
    end
  end

  private

  def left_buttons
    a(class: "btn", id: "mark-all", title: t("partials.action_bar.mark_all")) do
      i(class: "fa fa-check")
      render(Components::MarkAllAsReadForm.new(stories:))
    end
    whitespace
    title = t("partials.action_bar.refresh")
    a(class: "btn", href: "/", id: "refresh", title:) do
      i(class: "fa fa-refresh")
    end
  end

  def right_buttons
    title = t("partials.action_bar.view_feeds")
    a(class: "btn btn-primary", id: "feeds", href: "/feeds", title:) do
      i(class: "fa fa-list")
    end
    whitespace
    title = t("partials.action_bar.add_feed")
    a(class: "btn btn-primary", id: "add-feed", href: "/feeds/new", title:) do
      i(class: "fa fa-plus")
    end
  end
end
