require "spec_helper"

app_require "controllers/sessions_controller"

describe "SessionsController" do
  describe "GET /login" do
    it "has a password input and login button" do
      get "/login"

      page = last_response.body
      page.should have_tag("input#password")
      page.should have_tag("#login")
    end
  end

  describe "POST /login" do
    it "denies access when password is incorrect" do
      SignInUser.stub(:sign_in).and_return(nil)

      post "/login", password: "not-the-password"

      page = last_response.body
      page.should have_tag(".error")
    end

    it "allows access when password is correct" do
      SignInUser.stub(:sign_in).and_return(double(id: 1))

      post "/login", password: "the-password"

      session[:user_id].should eq 1

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/"
    end

    it "redirects to the previous path when present" do
      SignInUser.stub(:sign_in).and_return(double(id: 1))

      post "/login", { password: "the-password" },
        'rack.session' => { redirect_to: '/archive' }

      session[:redirect_to].should be_nil
      URI::parse(last_response.location).path.should eq "/archive"
    end
  end

  describe "GET /logout" do
    it "clears the session and redirects" do
      get "/logout", {}, 'rack.session' => {userid: 1}

      session[:user_id].should be_nil

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/"
    end
  end
end
