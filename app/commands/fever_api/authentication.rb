# frozen_string_literal: true

module FeverAPI::Authentication
  def self.call(authorization:, **_params)
    feeds = authorization.scope(Feed)
    last_refreshed_on_time = (feeds.maximum(:last_fetched) || 0).to_i

    { auth: 1, last_refreshed_on_time: }
  end
end
