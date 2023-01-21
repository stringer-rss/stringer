# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

RSpec.describe TutorialsController do
  describe "#index" do
    context "when a user has not been setup" do
      let(:user) { instance_double(User) }
      let(:feeds) { [instance_double(Feed), instance_double(Feed)] }

      it "displays the tutorial and completes setup" do
        user = create(:user)

        get "/setup/tutorial", {}, { "rack.session" => { user_id: user.id } }

        page = last_response.body
        expect(page).to have_tag("#mark-all-instruction")
      end
    end
  end
end
