# frozen_string_literal: true

class Views::Feeds::New < Views::Base
  attr_accessor :feed_url

  def initialize(feed_url:)
    super()
    self.feed_url = feed_url
  end

  def page_title = t("page_titles.add_feed")

  def view_template
    div(id: "action-bar") { render(Components::FeedActionBar.new) }

    div(class: "setup", id: "add-feed-container") do
      h1 { t("feeds.add.title") }
      hr
      p { t("feeds.add.description") }
      hr
      add_feed_form
    end
  end

  private

  def add_feed_form
    form_with(url: "/feeds", id: "add-feed-setup") do
      feed_url_field
      input(
        type: "submit",
        id: "submit",
        class: "btn btn-primary float-end",
        value: t("feeds.add.fields.submit")
      )
    end
  end

  def feed_url_field
    input = { name: "feed_url", id: "feed-url", value: feed_url }
    render(
      Components::IconField.new(
        input: input.merge(autofocus: true),
        icon: "fa-rss",
        label_id: "feed_url-label",
        label_text: t("feeds.add.fields.feed_url")
      )
    )
  end
end
