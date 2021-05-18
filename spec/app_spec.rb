require "spec_helper"
require "support/active_record"

describe "App" do
  context "when user is not authenticated and page requires authentication" do
    it "sets the session redirect_to" do
      create_user(:setup_complete)

      get("/news")

      expect(session[:redirect_to]).to eq("/news")
    end

    it "redirects to /login" do
      create_user(:setup_complete)

      get("/news")

      expect(last_response).to be_redirect
      expect(last_response.headers["Location"]).to end_with("/login")
    end
  end

  it "does not redirect when page needs no authentication" do
    create_user(:setup_complete)

    get("/login")

    expect(last_response).not_to be_redirect
  end

  it "does not redirect when user is authenticated" do
    user = create_user(:setup_complete)

    get("/news", {}, "rack.session" => { user_id: user.id })

    expect(last_response).not_to be_redirect
  end
end
