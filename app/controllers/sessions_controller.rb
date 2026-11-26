# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [:new, :create]

  def new
    authorization.skip
    render(Views::Sessions::New.new)
  end

  def create
    authorization.skip
    user = SignInUser.call(params[:username], params[:password])
    if user
      log_in(user)
    else
      flash.now[:error] = t("sessions.new.flash.wrong_password")
      render(Views::Sessions::New.new)
    end
  end

  def destroy
    authorization.skip
    flash[:success] = t("sessions.destroy.flash.logged_out_successfully")
    session[:user_id] = nil

    redirect_to("/")
  end

  private

  def log_in(user)
    session[:user_id] = user.id

    redirect_uri = session.delete(:redirect_to) || "/"
    redirect_to(redirect_uri)
  end
end
