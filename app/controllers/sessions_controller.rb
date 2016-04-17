require_relative "../commands/users/sign_in_user"

class Stringer < Sinatra::Base
  get "/login" do
    redirect to("/setup/password") unless UserRepository.created?

    if authenticated?
      redirect_uri = UserRepository.setup_complete? ? session.delete(:redirect_to) || "/news" : "/setup/tutorial"
      redirect to(redirect_uri)
    end

    erb :"sessions/new"
  end

  post "/login" do
    user = SignInUser.sign_in(params[:password])
    if user
      session[:user_id] = user.id

      redirect_uri = UserRepository.setup_complete? ? session.delete(:redirect_to) || "/news" : "/setup/tutorial"
      redirect to(redirect_uri)
    else
      flash.now[:error] = t("sessions.new.flash.wrong_password")
      erb :"sessions/new"
    end
  end

  get "/logout" do
    flash[:success] = t("sessions.destroy.flash.logged_out_successfully")
    session[:user_id] = nil

    redirect to("/")
  end
end
