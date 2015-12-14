module FeverAPI
  class Authentication
    def initialize(options = {})
      @clock = options.fetch(:clock){ Time }
    end

    def call(_params)
      { auth: 1, last_refreshed_on_time: @clock.now.to_i }
    end
  end
end
