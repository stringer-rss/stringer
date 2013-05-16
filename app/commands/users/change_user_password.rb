require_relative "../../repositories/user_repository"

class ChangeUserPassword
  def initialize(repository = UserRepository)
    @repo = repository
  end

  def change_user_password(new_password)
    user = @repo.first
    user.password = new_password

    @repo.save(user)
    user
  end
end
