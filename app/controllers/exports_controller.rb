# frozen_string_literal: true

require_relative "../commands/feeds/export_to_opml"

class ExportsController < ApplicationController
  def index
    xml = ExportToOpml.call(Feed.all)

    send_data(
      xml,
      type: "application/xml",
      disposition: "attachment",
      filename: "stringer.opml"
    )
  end
end
