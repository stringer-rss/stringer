# frozen_string_literal: true

class Views::Feeds::Index < Views::Base
  TOOLTIP_SCRIPT = <<~JS
    document.addEventListener("DOMContentLoaded", function () {
      document.querySelectorAll(".status").forEach(function(el) {
        new bootstrap.Tooltip(el);
      });
    });
  JS
  LINK_PLACEHOLDER = "\0"

  attr_accessor :feeds

  def initialize(feeds:)
    super()
    self.feeds = feeds
  end

  def view_template
    div(id: "action-bar") { render(Components::FeedActionBar.new) }

    if feeds.empty?
      add_some_feeds
    else
      feed_list
    end

    script(type: "text/javascript") { raw(safe(TOOLTIP_SCRIPT)) }
  end

  private

  def feed_list
    div(id: "feeds-container") do
      ul(id: "feed-list") do
        feeds.each { |feed| render(Components::FeedItem.new(feed:)) }
      end
    end
  end

  # Split the sentence around the link so the link can be a real tag
  # instead of HTML interpolated into the translation.
  def add_some_feeds
    message = t("feeds.index.add_some_feeds", add: LINK_PLACEHOLDER)
    before, after = message.split(LINK_PLACEHOLDER, 2)

    div(id: "add-some-feeds") do
      p do
        plain(before)
        a(href: "/feeds/new") { t("feeds.index.add") }
        plain(after.to_s)
      end
    end
  end
end
