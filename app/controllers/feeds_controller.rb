# frozen_string_literal: true

class FeedsController < ApplicationController
  def index
    feeds = authorization.scope(FeedRepository.list.with_unread_stories_counts)
    render(Views::Feeds::Index.new(feeds:))
  end

  def show
    feed = FeedRepository.fetch(params[:feed_id])
    authorization.check(feed)

    stories = StoryRepository.feed(params[:feed_id])
    unread_stories = stories.reject(&:is_read)
    render(Views::Feeds::Show.new(feed:, stories:, unread_stories:))
  end

  def new
    authorization.skip
    render(Views::Feeds::New.new(feed_url: params[:feed_url]))
  end

  def edit
    feed = FeedRepository.fetch(params[:id])
    authorization.check(feed)
    render_edit(feed)
  end

  def create
    authorization.skip
    feed_url = params[:feed_url]
    feed = Feed::Create.call(feed_url, user: current_user)

    if feed && feed.valid?
      CallableJob.perform_later(Feed::FetchOne, feed)

      redirect_to("/", flash: { success: t(".success") })
    else
      flash.now[:error] = create_error_message(feed)

      render(Views::Feeds::New.new(feed_url:))
    end
  end

  def update
    @feed = FeedRepository.fetch(params[:id])
    authorization.check(@feed)

    if update_feed
      flash[:success] = t("feeds.edit.flash.updated_successfully")
      redirect_to("/feeds")
    else
      flash.now[:error] = @feed.error_messages

      render_edit(@feed)
    end
  end

  def destroy
    authorization.check(Feed.find(params.expect(:id)))
    FeedRepository.delete(params[:id])

    flash[:success] = t(".success")
    redirect_to("/feeds")
  end

  private

  def render_edit(feed)
    render(Views::Feeds::Edit.new(feed:, groups: current_user.groups))
  end

  def update_feed
    FeedRepository.update_feed(
      @feed, params[:feed_name], params[:feed_url], params[:group_id]
    )
  end

  def create_error_message(feed)
    return t("feeds.create.feed_not_found") unless feed

    if feed.errors.of_kind?(:url, :taken)
      t("feeds.create.already_subscribed")
    else
      feed.error_messages
    end
  end
end
