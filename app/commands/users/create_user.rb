class CreateUser
  attr_accessor :repo
  def initialize(repository = User)
    @repo = repository
  end

  def create(password)
    repo.create(password: password, password_confirmation: password, setup_complete: false)
  end
end
