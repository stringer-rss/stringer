require_relative "../commands/stories/mark_feed_as_read"

module FeverAPI
  class WriteMarkFeed
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
