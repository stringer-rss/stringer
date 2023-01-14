# frozen_string_literal: true

class PasswordsController < ApplicationController
  before_action :redirect_if_setup_complete

  def new; end

  def create
    if no_password(params) || password_mismatch?(params)
      flash.now[:error] = t("first_run.password.flash.passwords_dont_match")
      render(:new)
    else
      user = CreateUser.call(params[:password])
      session[:user_id] = user.id

      redirect_to("/feeds/import")
    end
  end

  private

  def no_password(params)
    params[:password].nil? || params[:password] == ""
  end

  def password_mismatch?(params)
    params[:password] != params[:password_confirmation]
  end

  def redirect_if_setup_complete
    redirect_to("/news") if UserRepository.setup_complete?
  end
end
