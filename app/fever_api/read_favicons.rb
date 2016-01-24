module FeverAPI
  class ReadFavicons
    def call(params = {})
      if params.keys.include?("favicons")
        { favicons: favicons }
      else
        {}
      end
    end

    private

    def favicons
      [
        {
          id: 0,
          data: "image/gif;base64,R0lGODlhAQABAIAAAObm5gAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
        }
      ]
    end
  end
end
