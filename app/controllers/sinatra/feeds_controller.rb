require_relative "../../repositories/feed_repository"
require_relative "../../commands/feeds/add_new_feed"
require_relative "../../commands/feeds/export_to_opml"

class Stringer < Sinatra::Base
  get "/feeds/import" do
    erb :'feeds/import'
  end

  post "/feeds/import" do
    ImportFromOpml.import(params["opml_file"][:tempfile].read)

    redirect to("/setup/tutorial")
  end

  get "/feeds/export" do
    content_type "application/xml"
    attachment "stringer.opml"

    ExportToOpml.new(Feed.all).to_xml
  end
end
