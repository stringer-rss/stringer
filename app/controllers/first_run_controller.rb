require_relative "../commands/feeds/import_from_opml"

class Stringer < Sinatra::Base
  get "/import" do
    erb :import
  end

  post "/import" do
    ImportFromOpml.import(params["opml_file"][:tempfile].read, true)

    redirect to("/")
  end
end