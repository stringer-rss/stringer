# frozen_string_literal: true

module FeverAPI
  module WriteMarkGroup
    def self.call(params)
      if params[:mark] == "group"
        MarkGroupAsRead.new(params[:id], params[:before]).mark_group_as_read
      end

      {}
    end
  end
end
