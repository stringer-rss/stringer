# frozen_string_literal: true

module FeverAPI::WriteMarkFeed
  def self.call(params)
    MarkFeedAsRead.call(params[:id], params[:before]) if params[:mark] == "feed"

    {}
  end
end
