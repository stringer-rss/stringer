# frozen_string_literal: true

module FeverAPI
  module WriteMarkItem
    class << self
      def call(params)
        mark_item_as(params[:id], params[:as]) if params[:mark] == "item"

        {}
      end

      private

      def mark_item_as(id, mark_as)
        case mark_as
        when "read"
          MarkAsRead.call(id)
        when "unread"
          MarkAsUnread.call(id)
        when "saved"
          MarkAsStarred.call(id)
        when "unsaved"
          MarkAsUnstarred.call(id)
        end
      end
    end
  end
end
