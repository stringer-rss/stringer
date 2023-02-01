# frozen_string_literal: true

require "spec_helper"

describe "AssetPipeline" do
  include RequestHelpers

  it "handles asset requests" do
    get("/assets/stylesheets/application.css")

    expect(response.body).to match("#feed-title")
  end
end
