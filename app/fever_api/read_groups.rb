module FeverAPI
  class ReadGroups
    def call(params = {})
      if params.keys.include?('groups')
        { groups: groups }
      else
        {}
      end
    end

    private

    def groups
      [
        {
          id: 1,
          title: "All items"
        }
      ]
    end
  end
end
