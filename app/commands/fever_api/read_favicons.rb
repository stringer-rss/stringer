# frozen_string_literal: true

module FeverAPI
  class ReadFavicons
    ICON = "R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="

    def self.call(params)
      new.call(params)
    end

    def call(params = {})
      if params.keys.include?("favicons")
        { favicons: }
      else
        {}
      end
    end

    private

    def favicons
      [
        {
          id: 0,
          data: "image/gif;base64,#{ICON}"
        }
      ]
    end
  end
end
