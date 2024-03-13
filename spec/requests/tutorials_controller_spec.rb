# frozen_string_literal: true

RSpec.describe TutorialsController do
  describe "#index" do
    context "when a user has not been setup" do
      it "displays the tutorial and completes setup" do
        login_as(default_user)

        get "/setup/tutorial"

        expect(rendered).to have_css("#mark-all-instruction")
      end
    end
  end
end
