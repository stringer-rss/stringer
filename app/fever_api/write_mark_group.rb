require_relative "../commands/stories/mark_group_as_read"

module FeverAPI
  class WriteMarkGroup
    def initialize(options = {})
      @marker_class = options.fetch(:marker_class) { MarkGroupAsRead }
    end

    def call(params = {})
      @marker_class.new(params[:id], params[:before]).mark_group_as_read if params[:mark] == "group"

      {}
    end
  end
end
