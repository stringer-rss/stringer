# frozen_string_literal: true

class AccountsController < ApplicationController
  def show
    authorization.skip

    render(Views::Accounts::Show.new(user: current_user))
  end

  def update
    authorization.skip

    if current_user.update(user_params)
      redirect_to(news_path, flash: { success: t(".success") })
    else
      errors = current_user.error_messages
      flash.now[:error] = t(".failure", errors:)
      render(Views::Accounts::Show.new(user: current_user))
    end
  end

  def remove
    authorization.skip

    render(Views::Accounts::Remove.new(user: current_user))
  end

  def destroy
    authorization.skip

    UserRepository.delete(current_user)
    reset_session

    redirect_to("/", flash: { success: t(".success") })
  end

  private

  def user_params
    params.expect(
      user: [:username, :password_challenge, :stories_order, :group_stories]
    )
  end
end
