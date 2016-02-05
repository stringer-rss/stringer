require_relative "../commands/stories/mark_feed_as_read"

module FeverAPI
  class WriteMarkFeed
    def initialize(options = {})
      @marker_class = options.fetch(:marker_class) { MarkFeedAsRead }
    end

    def call(params = {})
      @marker_class.new(params[:id], params[:before]).mark_feed_as_read if params[:mark] == "feed"

      {}
    end
  end
end
