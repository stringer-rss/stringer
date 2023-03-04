# frozen_string_literal: true

module FeverAPI
  module WriteMarkFeed
    def self.call(params)
      if params[:mark] == "feed"
        MarkFeedAsRead.call(params[:id], params[:before])
      end

      {}
    end
  end
end
