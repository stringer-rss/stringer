# frozen_string_literal: true

module FeverAPI
  class ReadFavicons
    ICON = "R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="

    class << self
      def call(params)
        if params.key?(:favicons)
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
end
