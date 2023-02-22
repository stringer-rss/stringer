# frozen_string_literal: true

require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/add_new_feed"
require_relative "../commands/feeds/export_to_opml"

class FeedsController < ApplicationController
  def index
    @feeds = FeedRepository.list
  end

  def show
    @feed = FeedRepository.fetch(params[:feed_id])

    @stories = StoryRepository.feed(params[:feed_id])
    @unread_stories = @stories.reject(&:is_read)
  end

  def new
    @feed_url = params[:feed_url]
  end

  def edit
    @feed = FeedRepository.fetch(params[:id])
  end

  def create
    @feed_url = params[:feed_url]
    feed = AddNewFeed.call(@feed_url, user: current_user)

    unless feed && feed.valid?
      flash.now[:error] = feed ? t(".already_subscribed") : t(".feed_not_found")

      render(:new)
      return
    end

    FetchFeeds.enqueue([feed])

    flash[:success] = t(".success")
    redirect_to("/")
  end

  def update
    feed = FeedRepository.fetch(params[:id])

    FeedRepository.update_feed(
      feed,
      params[:feed_name],
      params[:feed_url],
      params[:group_id]
    )

    flash[:success] = t("feeds.edit.flash.updated_successfully")
    redirect_to("/feeds")
  end

  def destroy
    FeedRepository.delete(params[:id])

    flash[:success] = t(".success")
    redirect_to("/feeds")
  end
end
