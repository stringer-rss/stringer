# frozen_string_literal: true

module FeverAPI
  class WriteMarkFeed
    def self.call(params)
      new.call(params)
    end

    def initialize(options = {})
      @marker_class = options.fetch(:marker_class) { MarkFeedAsRead }
    end

    def call(params = {})
      if params[:mark] == "feed"
        @marker_class.new(params[:id], params[:before]).mark_feed_as_read
      end

      {}
    end
  end
end
