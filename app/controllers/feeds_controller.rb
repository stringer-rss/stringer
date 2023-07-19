# frozen_string_literal: true

class FeedsController < ApplicationController
  def index
    @feeds = authorization.scope(FeedRepository.list.with_unread_stories_counts)
  end

  def show
    @feed = FeedRepository.fetch(params[:feed_id])
    authorization.check(@feed)

    @stories = StoryRepository.feed(params[:feed_id])
    @unread_stories = @stories.reject(&:is_read)
  end

  def new
    authorization.skip
    @feed_url = params[:feed_url]
  end

  def edit
    @feed = FeedRepository.fetch(params[:id])
    authorization.check(@feed)
  end

  def create
    authorization.skip
    @feed_url = params[:feed_url]
    feed = Feed::Create.call(@feed_url, user: current_user)

    if feed && feed.valid?
      CallableJob.perform_later(Feed::FetchOne, feed)

      redirect_to("/", flash: { success: t(".success") })
    else
      flash.now[:error] = feed ? t(".already_subscribed") : t(".feed_not_found")

      render(:new)
    end
  end

  def update
    feed = FeedRepository.fetch(params[:id])
    authorization.check(feed)

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
    authorization.check(Feed.find(params[:id]))
    FeedRepository.delete(params[:id])

    flash[:success] = t(".success")
    redirect_to("/feeds")
  end
end
