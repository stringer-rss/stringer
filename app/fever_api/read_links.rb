module FeverAPI
  class ReadLinks
    def call(params = {})
      if params.keys.include?('links')
        { links: links }
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
