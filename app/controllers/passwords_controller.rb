# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_before_action :complete_setup, only: [:new, :create]
  skip_before_action :authenticate_user, only: [:new, :create]
  before_action :check_signups_enabled, only: [:new, :create]

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

  def check_signups_enabled
    redirect_to(login_path) unless Setting::UserSignup.enabled?
  end

  def password_params
    params
      .expect(user: [
                :password_challenge,
                :password,
                :password_confirmation
              ])
  end

  def user_params
    params
      .expect(user: [:username, :password, :password_confirmation])
      .merge(admin: User.none?)
      .to_h.symbolize_keys
  end
end
