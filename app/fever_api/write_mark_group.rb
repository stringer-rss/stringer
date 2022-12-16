require_relative "../commands/stories/mark_group_as_read"

module FeverAPI
  class WriteMarkGroup
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
