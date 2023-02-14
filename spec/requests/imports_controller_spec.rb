# frozen_string_literal: true

require "spec_helper"

describe ImportsController, type: :request do
  describe "GET /feeds/import" do
    it "displays the import options" do
      login_as(create(:user))

      get "/feeds/import"

      page = response.body
      expect(page).to have_tag("input#opml_file")
    end
  end

  describe "POST /feeds/import" do
    let(:opml_file) do
      Rack::Test::UploadedFile.new(
        "spec/sample_data/subscriptions.xml",
        "application/xml"
      )
    end

    it "parses OPML and starts fetching" do
      expect(ImportFromOpml).to receive(:call).once
      login_as(create(:user))

      post "/feeds/import", params: { opml_file: }
    end
  end
end
