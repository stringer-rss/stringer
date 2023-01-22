# frozen_string_literal: true

require_relative "../../repositories/user_repository"

class ChangeUserPassword
  def initialize(repository = UserRepository)
    @repo = repository
  end

  def change_user_password(new_password)
    user = @repo.first
    user.password = user.password_confirmation = new_password
    user.regenerate_api_key

    @repo.save(user)
    user
  end
end
