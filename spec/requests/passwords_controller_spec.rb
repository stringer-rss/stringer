# frozen_string_literal: true

RSpec.describe PasswordsController do
  describe "#new" do
    it "displays a form to enter your password" do
      get "/setup/password"

      expect(rendered).to have_css("form#password_setup")
    end

    it "redirects to the login page when signups are not enabled" do
      create(:user)
      Setting::UserSignup.update!(enabled: false)

      get "/setup/password"

      expect(response).to redirect_to(login_path)
    end
  end

  describe "#create" do
    it "rejects empty passwords" do
      post "/setup/password",
           params: { user: { password: "", password_confirmation: "" } }

      expect(rendered).to have_text("Password can't be blank")
    end

    it "rejects when password isn't confirmed" do
      post "/setup/password",
           params: { user: { password: "foo", password_confirmation: "bar" } }

      expect(rendered).to have_text("confirmation doesn't match")
    end

    it "accepts confirmed passwords and redirects to next step" do
      user_params =
        { username: "foo", password: "foo", password_confirmation: "foo" }

      post "/setup/password", params: { user: user_params }

      expect(response).to redirect_to("/feeds/import")
    end

    it "redirects to the login page when signups are not enabled" do
      create(:user)
      Setting::UserSignup.update!(enabled: false)

      post "/setup/password"

      expect(response).to redirect_to(login_path)
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
