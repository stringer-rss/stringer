class CreateUser
  def initialize(repository = User)
    @repo = repository
  end

  def create(password)
    @repo.delete_all
    @repo.create(password: password, password_confirmation: password, setup_complete: false)
  end
end