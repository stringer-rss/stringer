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

    @unread_stories = authorization.scope(scope)
  end

  def update
    json_params = JSON.parse(request.body.read, symbolize_names: true)

    story = authorization.check(StoryRepository.fetch(params[:id]))
    story.update!(json_params.slice(:is_read, :is_starred, :keep_unread))

    head(:no_content)
  end

  def mark_all_as_read
    stories = authorization.scope(Story.where(id: params[:story_ids]))
    MarkAllAsRead.call(stories.ids)

    redirect_to("/news")
  end

  def archived
    @read_stories = authorization.scope(StoryRepository.read(params[:page]))
  end

  def starred
    @starred_stories =
      authorization.scope(StoryRepository.starred(params[:page]))
  end
end
