require_relative "../commands/stories/mark_group_as_read"

module FeverAPI
  class WriteMarkGroup
    def call(params)
      if params[:mark] == "group"
        MarkGroupAsRead.new(params[:id], params[:before]).mark_group_as_read
      end

      {}
    end
  end
end
