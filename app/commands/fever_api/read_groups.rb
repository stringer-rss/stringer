# frozen_string_literal: true

module FeverAPI::ReadGroups
  class << self
    def call(authorization:, **params)
      if params.key?(:groups)
        { groups: groups(authorization) }
      else
        {}
      end
    end

    private

    def groups(authorization)
      [Group::UNGROUPED, *authorization.scope(GroupRepository.list)]
        .map(&:as_fever_json)
    end
  end
end
