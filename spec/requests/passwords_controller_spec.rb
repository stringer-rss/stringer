# frozen_string_literal: true

RSpec.describe PasswordsController do
  def setup
    expect(UserRepository).to receive(:setup_complete?).and_return(false)
  end

  describe "#new" do
    it "displays a form to enter your password" do
      setup

      get "/setup/password"

      expect(rendered).to have_selector("form#password_setup")
    end

    it "redirects to the news path if setup is complete" do
      create(:user)

      get "/setup/password"

      expect(response).to redirect_to("/news")
    end
  end

  describe "#create" do
    it "rejects empty passwords" do
      setup

      post "/setup/password"

      expect(rendered).to have_selector("div.error")
    end

    it "rejects when password isn't confirmed" do
      setup

      post "/setup/password",
           params: { password: "foo", password_confirmation: "bar" }

      expect(rendered).to have_selector("div.error")
    end

    it "accepts confirmed passwords and redirects to next step" do
      post "/setup/password",
           params: { password: "foo", password_confirmation: "foo" }

      expect(URI.parse(response.location).path).to eq("/feeds/import")
    end
  end

  describe "#update" do
    def params(old_password, new_password)
      {
        user: {
          password_challenge: old_password,
          password: new_password,
          password_confirmation: new_password
        }
      }
    end

    context "when the password info is correct" do
      it "updates the password" do
        user = create(:user, password: "old_password")
        login_as(user)

        put("/password", params: params("old_password", "new_password"))

        expect(user.reload.authenticate("new_password")).to eq(user)
      end

      it "redirects to the news page" do
        user = create(:user, password: "old_password")
        login_as(user)

        put("/password", params: params("old_password", "new_password"))

        expect(response).to redirect_to("/news")
      end
    end

    context "when the password info is incorrect" do
      it "displays an error message" do
        user = create(:user, password: "old_password")
        login_as(user)

        put("/password", params: params("wrong_password", "new_password"))

        expect(rendered).to have_text("Unable to update password")
      end

      it "renders the edit profile page" do
        user = create(:user, password: "old_password")
        login_as(user)

        put("/password", params: params("wrong_password", "new_password"))

        expect(rendered).to have_text("Edit profile")
      end

      it "doesn't update the password" do
        user = create(:user, password: "old_password")
        login_as(user)

        put("/password", params: params("wrong_password", "new_password"))

        expect(user.reload.authenticate("new_password")).to be_falsey
      end
    end
  end
end
