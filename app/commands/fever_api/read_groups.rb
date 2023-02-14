# frozen_string_literal: true

module FeverAPI
  class ReadGroups
    def self.call(params)
      new.call(params)
    end

    def initialize(options = {})
      @group_repository = options.fetch(:group_repository) { GroupRepository }
    end

    def call(params = {})
      if params.keys.include?("groups")
        { groups: }
      else
        {}
      end
    end

    private

    def groups
      @group_repository.list.map(&:as_fever_json)
    end
  end
end
