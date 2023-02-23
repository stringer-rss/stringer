# frozen_string_literal: true

RSpec.describe TutorialsController do
  describe "#index" do
    context "when a user has not been setup" do
      let(:user) { instance_double(User) }
      let(:feeds) { [instance_double(Feed), instance_double(Feed)] }

      it "displays the tutorial and completes setup" do
        login_as(default_user)

        get "/setup/tutorial"

        expect(rendered).to have_selector("#mark-all-instruction")
      end
    end
  end
end
