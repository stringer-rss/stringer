# frozen_string_literal: true

module FeverAPI::WriteMarkGroup
  def self.call(authorization:, **params)
    if params[:mark] == "group"
      authorization.check(Group.find(params[:id]))
      MarkGroupAsRead.call(params[:id], params[:before])
    end

    {}
  end
end
