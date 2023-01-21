# frozen_string_literal: true

require "spec_helper"

describe "AssetPipeline" do
  include ControllerHelpers

  it "handles asset requests" do
    get("/assets/stylesheets/application.css")

    expect(last_response.body).to match("#feed-title")
  end
end
