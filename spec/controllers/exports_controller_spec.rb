# frozen_string_literal: true

require "spec_helper"

app_require "controllers/exports_controller"

describe ExportsController do
  describe "GET /feeds/export" do
    def expected_xml
      <<~XML
        <?xml version="1.0"?>
        <opml version="1.0">
          <head>
            <title>Feeds from Stringer</title>
          </head>
          <body/>
        </opml>
      XML
    end

    it "returns an OPML file" do
      get "/feeds/export"

      expect(last_response.body).to eq(expected_xml)
    end

    it "responds with xml content type" do
      get "/feeds/export"

      expect(last_response.header["Content-Type"]).to include("application/xml")
    end

    it "responds with disposition attachment" do
      get "/feeds/export"

      expected =
        "attachment; filename=\"stringer.opml\"; filename*=UTF-8''stringer.opml"
      expect(last_response.header["Content-Disposition"]).to eq(expected)
    end
  end
end
