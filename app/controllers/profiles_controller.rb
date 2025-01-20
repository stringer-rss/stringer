# frozen_string_literal: true

class ProfilesController < ApplicationController
  def edit
    authorization.skip

    render(locals: { user: current_user })
  end

  def update
    authorization.skip

    if current_user.update(user_params)
      redirect_to(news_path, flash: { success: t(".success") })
    else
      errors = current_user.error_messages
      flash.now[:error] = t(".failure", errors:)
      render(:edit, locals: { user: current_user })
    end
  end

  private

  def user_params
    params.expect(user: [:username, :password_challenge, :stories_order])
  end
end
