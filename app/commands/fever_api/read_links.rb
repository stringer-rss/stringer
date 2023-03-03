# frozen_string_literal: true

module FeverAPI
  module ReadLinks
    def self.call(params)
      if params.key?(:links)
        { links: [] }
      else
        {}
      end
    end
  end
end
