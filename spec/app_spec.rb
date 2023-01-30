# frozen_string_literal: true

require "spec_helper"

describe "App" do
  include ControllerHelpers

  describe "Rails" do
    it "returns a fake application" do
      expect(Rails.application.config.cache_classes).to be(true)
    end
  end
end
