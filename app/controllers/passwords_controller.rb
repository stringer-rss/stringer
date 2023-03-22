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

    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id

      redirect_to("/feeds/import")
    else
      flash.now[:error] = user.error_messages
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

  def user_params
    params.require(:user)
          .permit(:password, :password_confirmation)
          .merge(username: "stringer", admin: User.none?)
          .to_h.symbolize_keys
  end

  def redirect_if_setup_complete
    redirect_to("/news") if UserRepository.setup_complete?
  end
end
