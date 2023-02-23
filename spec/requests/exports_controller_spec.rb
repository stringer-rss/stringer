# frozen_string_literal: true

RSpec.describe ExportsController do
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
      login_as(default_user)

      get "/feeds/export"

      expect(response.body).to eq(expected_xml)
    end

    it "responds with xml content type" do
      login_as(default_user)

      get "/feeds/export"

      expect(response.header["Content-Type"]).to include("application/xml")
    end

    it "responds with disposition attachment" do
      login_as(default_user)

      get "/feeds/export"

      expected =
        "attachment; filename=\"stringer.opml\"; filename*=UTF-8''stringer.opml"
      expect(response.header["Content-Disposition"]).to eq(expected)
    end
  end
end
