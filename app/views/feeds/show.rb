# frozen_string_literal: true

class Views::Feeds::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor

  attr_accessor :feed, :stories, :unread_stories

  def initialize(feed:, stories:, unread_stories:)
    super()
    self.feed = feed
    self.stories = stories
    self.unread_stories = unread_stories
  end

  def view_template
    unless unread_stories.empty?
      content_for(:title, "(#{unread_stories.count})")
    end

    div(id: "action-bar") do
      render(
        Components::SingleFeedActionBar.new(feed:, stories: unread_stories)
      )
    end

    div(id: "feed-title") { feed.name }

    render(Components::StoryList.new(stories:))
  end
end
