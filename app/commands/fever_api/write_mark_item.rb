# frozen_string_literal: true

module FeverAPI
  class WriteMarkItem
    def self.call(params)
      new.call(params)
    end

    def initialize(options = {})
      @read_marker_class = options.fetch(:read_marker_class) { MarkAsRead }
      @unread_marker_class =
        options.fetch(:unread_marker_class) { MarkAsUnread }
      @starred_marker_class =
        options.fetch(:starred_marker_class) { MarkAsStarred }
      @unstarred_marker_class =
        options.fetch(:unstarred_marker_class) { MarkAsUnstarred }
    end

    def call(params = {})
      mark_item_as(params[:id], params[:as]) if params[:mark] == "item"

      {}
    end

    private

    def mark_item_as(id, mark_as)
      case mark_as
      when "read"
        @read_marker_class.call(id)
      when "unread"
        @unread_marker_class.call(id)
      when "saved"
        @starred_marker_class.call(id)
      when "unsaved"
        @unstarred_marker_class.call(id)
      end
    end
  end
end
