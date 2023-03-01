# frozen_string_literal: true

RSpec.describe APIKeysController do
  it "regenerates the user's API key" do
    login_as(default_user)
    existing_api_key = default_user.api_key

    expect { patch(api_key_path) }
      .to change_record(default_user, :api_key).from(existing_api_key)
  end

  it "redirects to the profile page" do
    login_as(default_user)

    patch(api_key_path)

    expect(response).to redirect_to(edit_profile_path)
  end

  it "displays a success message" do
    login_as(default_user)

    patch(api_key_path)

    expect(flash[:success]).to eq("API key regenerated")
  end
end
