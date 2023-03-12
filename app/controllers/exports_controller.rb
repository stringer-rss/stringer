# frozen_string_literal: true

class ExportsController < ApplicationController
  def index
    xml = Feed::ExportToOpml.call(authorization.scope(Feed.all))

    send_data(
      xml,
      type: "application/xml",
      disposition: "attachment",
      filename: "stringer.opml"
    )
  end
end
