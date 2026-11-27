# frozen_string_literal: true

class Views::Feeds::Show < Views::Base
  attr_accessor :feed, :stories, :unread_stories

  def initialize(feed:, stories:, unread_stories:)
    super()
    self.feed = feed
    self.stories = stories
    self.unread_stories = unread_stories
  end

  def page_title
    "(#{unread_stories.count})" unless unread_stories.empty?
  end

  def view_template
    div(id: "action-bar") do
      render(
        Components::SingleFeedActionBar.new(feed:, stories: unread_stories)
      )
    end

    div(id: "feed-title") { feed.name }

    render(Components::StoryList.new(stories:))
  end
end
