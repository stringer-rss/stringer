# frozen_string_literal: true

class Views::Feeds::Edit < Views::Base
  attr_accessor :feed, :groups

  def initialize(feed:, groups:)
    super()
    self.feed = feed
    self.groups = groups
  end

  def view_template
    div(id: "action-bar") { render(Components::FeedActionBar.new) }

    div(class: "setup", id: "add-feed-container") do
      h1 { feed.name }
      hr
      edit_feed_form
    end
  end

  private

  def edit_feed_form
    url = "/feeds/#{feed.id}"
    form_with(url:, method: :put, id: "add-feed-setup") do
      input(type: "hidden", name: "feed_id", value: feed.id)
      feed_name_field
      feed_url_field
      group_field if groups.any?
      submit_button
    end
  end

  def feed_name_field
    input = { name: "feed_name", id: "feed-name", value: feed.name }
    render(
      Components::IconField.new(
        input: input.merge(required: true),
        icon: "fa-pencil",
        label_id: "feed-name-label",
        label_text: t("feeds.edit.fields.feed_name")
      )
    )
  end

  def feed_url_field
    input = { name: "feed_url", id: "feed-url", value: feed.url }
    render(
      Components::IconField.new(
        input: input.merge(autofocus: true, required: true),
        icon: "fa-rss",
        label_id: "feed-url-label",
        label_text: t("feeds.edit.fields.feed_url")
      )
    )
  end

  def group_field
    div do
      input(type: "text", class: "form-control", tabindex: "-1")
      group_select
      label(id: "group_id-label", class: "field-label", for: "group_id") do
        t("feeds.edit.fields.group")
      end
    end
  end

  def group_select
    select(name: "group_id", id: "group-id") do
      option(value: "")
      groups.each do |group|
        selected = feed.group_id == group.id
        option(value: group.id, selected:) { group.name }
      end
    end
  end

  def submit_button
    input(
      type: "submit",
      id: "submit",
      class: "btn btn-primary float-end",
      value: t("feeds.edit.fields.submit")
    )
  end
end
