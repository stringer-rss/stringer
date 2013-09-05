require_relative "../commands/stories/mark_as_read"
require_relative "../commands/stories/mark_as_unread"
require_relative "../commands/stories/mark_as_starred"
require_relative "../commands/stories/mark_as_unstarred"

module FeverAPI
  class WriteMarkItem
    def initialize(options = {})
      @read_marker_class = options.fetch(:read_marker_class) { MarkAsRead }
      @unread_marker_class = options.fetch(:unread_marker_class) { MarkAsUnread }
      @starred_marker_class = options.fetch(:starred_marker_class) { MarkAsStarred }
      @unstarred_marker_class = options.fetch(:unstarred_marker_class) { MarkAsUnstarred }
    end

    def call(params = {})
      if params[:mark] == "item"
        case params[:as]
        when "read"
          @read_marker_class.new(params[:id]).mark_as_read
        when "unread"
          @unread_marker_class.new(params[:id]).mark_as_unread
        when "saved"
          @starred_marker_class.new(params[:id]).mark_as_starred
        when "unsaved"
          @unstarred_marker_class.new(params[:id]).mark_as_unstarred
        end
      end

      {}
    end
  end
end
