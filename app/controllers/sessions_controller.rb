require_relative "../commands/users/sign_in_user"

class Stringer < Sinatra::Base
  get "/login" do
    erb :"sessions/new"
  end

  post "/login" do
    user = SignInUser.sign_in(params[:password])
    if user
      session[:user_id] = user.id

      if session[:redirect_to].present?
        redirect to(session.delete(:redirect_to))
      else
        redirect to("/")
      end
    else
      flash.now[:error] = t('sessions.new.flash.wrong_password')
      erb :"sessions/new"
    end
  end

  get "/logout" do
    flash[:success] = t('sessions.destroy.flash.logged_out_successfully')
    session[:user_id] = nil

    redirect to("/")
  end
end
