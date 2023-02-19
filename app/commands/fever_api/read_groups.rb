# frozen_string_literal: true

module FeverAPI
  module ReadGroups
    class << self
      def call(params)
        if params.keys.include?("groups")
          { groups: }
        else
          {}
        end
      end

      private

      def groups
        GroupRepository.list.map(&:as_fever_json)
      end
    end
  end
end
