# frozen_string_literal: true

module FeverAPI
  class WriteMarkGroup
    def self.call(params)
      new.call(params)
    end

    def initialize(options = {})
      @marker_class = options.fetch(:marker_class) { MarkGroupAsRead }
    end

    def call(params = {})
      if params[:mark] == "group"
        @marker_class.new(params[:id], params[:before]).mark_group_as_read
      end

      {}
    end
  end
end
