# frozen_string_literal: true

module FeverAPI::Authentication
  def self.call(_params)
    last_refreshed_on_time = (Feed.maximum(:last_fetched) || 0).to_i

    { auth: 1, last_refreshed_on_time: }
  end
end
