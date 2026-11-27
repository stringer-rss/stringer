# frozen_string_literal: true

class StoriesController < ApplicationController
  def index
    order = current_user.stories_order
    scope =
      if current_user.group_stories
        StoryRepository.unread_grouped_by_feed(order:)
      else
        StoryRepository.unread(order:)
      end

    stories = authorization.scope(scope)
    render(Views::Stories::Index.new(stories:))
  end

  def update
    json_params = JSON.parse(request.body.read, symbolize_names: true)

    story = authorization.check(StoryRepository.fetch(params[:id]))
    story.update!(json_params.slice(:is_read, :is_starred, :keep_unread))

    head(:no_content)
  end

  def refresh
    story = authorization.check(StoryRepository.fetch(params[:id]))

    # The refresh form submits inside the story's Turbo Frame, which swaps in
    # this response. On failure, render the story unchanged so the frame
    # still finds its content.
    status = RefreshFromFeed.call(story) ? :ok : :unprocessable_content
    render(Components::StoryFrame.new(story:), layout: false, status:)
  end

  def mark_all_as_read
    stories = authorization.scope(Story.where(id: params[:story_ids]))
    MarkAllAsRead.call(stories.ids)

    redirect_to("/news")
  end

  def archived
    stories = authorization.scope(StoryRepository.read(params[:page]))
    render(Views::Stories::Archived.new(stories:))
  end

  def starred
    stories = authorization.scope(StoryRepository.starred(params[:page]))
    render(Views::Stories::Starred.new(stories:))
  end
end
