require "spec_helper"

describe "AssetPipeline" do
  it "handles asset requests" do
    get("/assets/stylesheets/application.css")

    expect(last_response.body).to match("#feed-title")
  end
end
