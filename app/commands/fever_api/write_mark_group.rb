# frozen_string_literal: true

module FeverAPI
  module WriteMarkGroup
    def self.call(params)
      if params[:mark] == "group"
        MarkGroupAsRead.call(params[:id], params[:before])
      end

      {}
    end
  end
end
