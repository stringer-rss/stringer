# frozen_string_literal: true

RSpec.describe ImportsController do
  describe "GET /feeds/import" do
    it "displays the import options" do
      login_as(default_user)

      get "/feeds/import"

      expect(rendered).to have_field("opml_file")
    end
  end

  describe "POST /feeds/import" do
    opml_file = Rack::Test::UploadedFile.new(
      "spec/sample_data/subscriptions.xml",
      "application/xml"
    )

    it "parses OPML and starts fetching" do
      expect(Feed::ImportFromOpml).to receive(:call).once
      login_as(default_user)

      post "/feeds/import", params: { opml_file: }
    end
  end
end
