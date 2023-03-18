# frozen_string_literal: true

module FeverAPI::WriteMarkFeed
  def self.call(authorization:, **params)
    if params[:mark] == "feed"
      authorization.check(Feed.find(params[:id]))
      MarkFeedAsRead.call(params[:id], params[:before])
    end

    {}
  end
end
