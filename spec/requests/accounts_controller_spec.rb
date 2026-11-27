# frozen_string_literal: true

RSpec.describe AccountsController do
  describe "#show" do
    it "displays the account view" do
      login_as(default_user)

      get(account_path)

      expect(rendered).to have_css("h1", text: "Account")
        .and have_field("Username", with: default_user.username)
        .and have_link("Delete account", href: remove_account_path)
    end
  end

  describe "#update" do
    context "when the user is valid" do
      it "updates the user's username" do
        login_as(default_user)
        password_challenge = default_user.password
        params = { user: { username: "new_username", password_challenge: } }

        expect { patch(account_path, params:) }
          .to change_record(default_user, :username).to("new_username")
      end

      it "redirects to the news path" do
        login_as(default_user)
        password_challenge = default_user.password
        params = { user: { username: "new_username", password_challenge: } }

        patch(account_path, params:)

        expect(response).to redirect_to(news_path)
      end
    end

    context "when the username is invalid" do
      it "displays an error message" do
        login_as(default_user)

        patch(account_path, params: { user: { username: "" } })

        expect(rendered).to have_text("Username can't be blank")
      end

      it "displays the account view" do
        login_as(default_user)

        patch(account_path, params: { user: { username: "" } })

        expect(rendered).to have_css("h1", text: "Account")
      end

      it "does not update the user's username" do
        login_as(default_user)

        params = { user: { username: "" } }

        expect { patch(account_path, params:) }
          .not_to change_record(default_user, :username)
      end
    end
  end

  describe "#remove" do
    it "displays a confirmation for deleting the account" do
      login_as(default_user)

      get(remove_account_path)

      expect(rendered).to have_text(default_user.username)
        .and have_button("Permanently delete account")
        .and have_link("Cancel", href: account_path)
    end
  end

  describe "#destroy" do
    it "deletes the user" do
      login_as(default_user)

      expect { delete(account_path) }.to delete_record(default_user)
    end

    it "logs the user out" do
      login_as(default_user)
      create(:user)

      delete(account_path)
      get(account_path)

      expect(response).to redirect_to("/login")
    end

    it "redirects to the root path" do
      login_as(default_user)

      delete(account_path)

      expect(response).to redirect_to("/")
    end

    it "shows a message that the account was deleted" do
      login_as(default_user)

      delete(account_path)

      expect(flash[:success]).to eq("Your account has been deleted")
    end
  end
end
