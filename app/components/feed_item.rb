# frozen_string_literal: true

class Components::FeedItem < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  attr_accessor :feed

  def initialize(feed:)
    super()
    self.feed = feed
  end

  def view_template
    li(class: "feed", id: "feed-#{feed.id}", data: { id: feed.id }) do
      div(class: "feed-line") do
        div(class: "feed-title-container") { title }
        div(class: "feed-actions") { actions }
      end
    end
  end

  private

  def title
    p(class: ["feed-title", ("feed-unread" if unread?)]) do
      status_icon
      whitespace
      a(href: "/feed/#{feed.id}") do
        plain("(#{feed.unread_stories_count}) ") if unread?
        plain(feed.name)
      end
    end
  end

  def status_icon
    i(
      class: "fa fa-circle status #{feed.status_bubble}",
      aria_hidden: "true",
      data: { controller: "tooltip", bs_toggle: "tooltip", placement: "left" },
      title: status_text.to_s
    )
    span(class: "sr-only") { status_text } if status_text
  end

  def actions
    last_updated
    read_link
    edit_link
    delete_button
  end

  def read_link
    span(class: "read-feed") do
      a(
        class: "fa fa-external-link",
        aria_label: "visit feed site",
        href: feed.url
      )
    end
  end

  def edit_link
    span(class: "edit-feed") do
      a(class: "fa fa-edit", aria_label: "Edit", href: "/feeds/#{feed.id}/edit")
    end
  end

  def last_updated
    div(class: "feed-last-updated") do
      span(class: "last-updated") { t("partials.feed.last_updated") }
      whitespace
      span(class: "last-updated-time") { last_fetched }
    end
  end

  def last_fetched
    return t("partials.feed.last_fetched.never") unless feed.last_fetched

    I18n.l(feed.last_fetched)
  end

  def delete_button
    options = { method: :delete, class: "remove-feed btn-link" }
    button_to("/feeds/#{feed.id}", **options, aria: { label: "Delete" }) do
      a(class: "fa fa-times")
    end
  end

  def unread?
    feed.unread_stories_count.positive?
  end

  def status_text
    return unless feed.status_bubble

    t(feed.status_bubble, scope: "partials.feed.status_bubble")
  end
end
