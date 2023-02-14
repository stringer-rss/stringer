# frozen_string_literal: true

module FeverAPI
  class ReadLinks
    def self.call(params)
      new.call(params)
    end

    def call(params = {})
      if params.keys.include?("links")
        { links: }
      else
        {}
      end
    end

    private

    def links
      []
    end
  end
end
