require_relative "../commands/stories/mark_as_read"
require_relative "../commands/stories/mark_as_unread"
require_relative "../commands/stories/mark_as_starred"
require_relative "../commands/stories/mark_as_unstarred"

module FeverAPI
  class WriteMarkItem
    def call(params)
      if params[:mark] == "item"
        case params[:as]
        when "read"
          MarkAsRead.new(params[:id]).mark_as_read
        when "unread"
          MarkAsUnread.new(params[:id]).mark_as_unread
        when "saved"
          MarkAsStarred.new(params[:id]).mark_as_starred
        when "unsaved"
          MarkAsUnstarred.new(params[:id]).mark_as_unstarred
        end
      end

      {}
    end
  end
end
