# frozen_string_literal: true

module FeverAPI
  module ReadLinks
    def self.call(params)
      if params.keys.include?("links")
        { links: [] }
      else
        {}
      end
    end
  end
end
