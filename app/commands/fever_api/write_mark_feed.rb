# frozen_string_literal: true

module FeverAPI
  module WriteMarkFeed
    def self.call(params)
      if params[:mark] == "feed"
        MarkFeedAsRead.new(params[:id], params[:before]).mark_feed_as_read
      end

      {}
    end
  end
end
