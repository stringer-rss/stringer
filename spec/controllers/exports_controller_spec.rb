require "spec_helper"

app_require "controllers/exports_controller"

describe ExportsController do
  describe "GET /feeds/export" do
    let(:some_xml) { "<xml>some dummy opml</xml>" }
    before { allow(Feed).to receive(:all) }

    it "returns an OPML file" do
      expect_any_instance_of(ExportToOpml).to receive(:to_xml).and_return(some_xml)

      get "/feeds/export"

      expect(last_response.body).to eq some_xml
    end

    it "responds with OPML headers" do
      expect_any_instance_of(ExportToOpml).to receive(:to_xml).and_return(some_xml)

      get "/feeds/export"

      expect(last_response.header["Content-Type"]).to include "application/xml"
      expect(last_response.header["Content-Disposition"])
        .to eq("attachment; filename=\"stringer.opml\"; filename*=UTF-8''stringer.opml")
    end
  end
end
