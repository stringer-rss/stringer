class ChangeUserPassword
  def initialize(repository = User)
    @repo = repository
  end

  def change_user_password(new_password)
    user = @repo.first
    user.password = new_password
    user.save
    user
  end
end
