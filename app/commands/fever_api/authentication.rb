# frozen_string_literal: true

module FeverAPI
  class Authentication
    def initialize(options = {})
      @clock = options.fetch(:clock) { Time }
    end

    def call(_params)
      last_refreshed_on_time = (Feed.maximum(:last_fetched) || 0).to_i

      { auth: 1, last_refreshed_on_time: }
    end
  end
end
