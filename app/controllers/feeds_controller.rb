# frozen_string_literal: true

class FeedsController < ApplicationController
  def index
    @feeds = FeedRepository.list
  end

  def new
    @feed_url = params[:feed_url]
  end

  def edit
    @feed = FeedRepository.fetch(params[:id])
  end

  def create
    @feed_url = params[:feed_url]
    feed = AddNewFeed.add(@feed_url)

    if feed && feed.valid?
      FetchFeeds.enqueue([feed])

      flash[:success] = t("feeds.add.flash.added_successfully")
      redirect_to("/")
    elsif feed
      flash.now[:error] = t("feeds.add.flash.already_subscribed_error")
      render(:new)
    else
      flash.now[:error] = t("feeds.add.flash.feed_not_found_error")
      render(:new)
    end
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

    head(:ok)
  end
end
