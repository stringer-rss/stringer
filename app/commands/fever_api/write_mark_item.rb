# frozen_string_literal: true

module FeverAPI::WriteMarkItem
  class << self
    def call(authorization:, **params)
      if params[:mark] == "item"
        authorization.check(Story.find(params[:id])) if params.key?(:id)
        mark_item_as(params[:id], params[:as])
      end

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
