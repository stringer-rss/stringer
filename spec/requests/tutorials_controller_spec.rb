# frozen_string_literal: true

require "spec_helper"

RSpec.describe TutorialsController, type: :request do
  describe "#index" do
    context "when a user has not been setup" do
      let(:user) { instance_double(User) }
      let(:feeds) { [instance_double(Feed), instance_double(Feed)] }

      it "displays the tutorial and completes setup" do
        login_as(create(:user))

        get "/setup/tutorial"

        page = last_response.body
        expect(page).to have_tag("#mark-all-instruction")
      end
    end
  end
end
