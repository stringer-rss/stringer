# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_before_action :complete_setup, only: [:new, :create]
  skip_before_action :authenticate_user, only: [:new, :create]
  before_action :redirect_if_setup_complete, only: [:new, :create]

  def new
    authorization.skip
  end

  def create
    authorization.skip

    if valid_password?(params)
      user = CreateUser.call(params[:password])
      session[:user_id] = user.id

      redirect_to("/feeds/import")
    else
      flash.now[:error] = t("first_run.password.flash.passwords_dont_match")
      render(:new)
    end
  end

  def update
    authorization.skip

    if current_user.update(password_params)
      redirect_to("/news", flash: { success: t(".success") })
    else
      flash.now[:error] = t(".failure", errors: current_user.error_messages)
      render("profiles/edit", locals: { user: current_user })
    end
  end

  private

  def password_params
    params.require(:user)
          .permit(:password_challenge, :password, :password_confirmation)
  end

  def valid_password?(params)
    !(no_password(params) || password_mismatch?(params))
  end

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
