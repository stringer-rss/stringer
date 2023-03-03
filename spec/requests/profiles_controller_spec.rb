# frozen_string_literal: true

RSpec.describe ProfilesController do
  describe "#edit" do
    it "displays the edit view" do
      login_as(default_user)

      get(edit_profile_path)

      expect(rendered).to have_text("Edit profile")
        .and have_field("Username", with: default_user.username)
    end
  end

  describe "#update" do
    context "when the user is valid" do
      it "updates the user's username" do
        login_as(default_user)
        password_challenge = default_user.password
        params = { user: { username: "new_username", password_challenge: } }

        expect { patch(profile_path, params:) }
          .to change_record(default_user, :username).to("new_username")
      end

      it "redirects to the news path" do
        login_as(default_user)
        password_challenge = default_user.password
        params = { user: { username: "new_username", password_challenge: } }

        patch(profile_path, params:)

        expect(response).to redirect_to(news_path)
      end
    end

    context "when the username is invalid" do
      it "displays an error message" do
        login_as(default_user)

        patch(profile_path, params: { user: { username: "" } })

        expect(rendered).to have_text("Username can't be blank")
      end

      it "displays the edit view" do
        login_as(default_user)

        patch(profile_path, params: { user: { username: "" } })

        expect(rendered).to have_text("Edit profile")
      end

      it "does not update the user's username" do
        login_as(default_user)

        params = { user: { username: "" } }

        expect { patch(profile_path, params:) }
          .not_to change_record(default_user, :username)
      end
    end
  end
end
