# frozen_string_literal: true

require "spec_helper"

app_require "controllers/imports_controller"

describe ImportsController do
  describe "GET /feeds/import" do
    it "displays the import options" do
      get "/feeds/import"

      page = last_response.body
      expect(page).to have_tag("input#opml_file")
      expect(page).to have_tag("a#skip")
    end
  end

  describe "POST /feeds/import" do
    let(:opml_file) do
      Rack::Test::UploadedFile.new(
        "spec/sample_data/subscriptions.xml",
        "application/xml"
      )
    end

    it "parse OPML and starts fetching" do
      expect(ImportFromOpml).to receive(:import).once

      post "/feeds/import", "opml_file" => opml_file

      expect(last_response.status).to be(302)
      expect(URI.parse(last_response.location).path).to eq("/setup/tutorial")
    end
  end
end
