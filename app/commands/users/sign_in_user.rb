require_relative "../../models/user"

class SignInUser
  def self.sign_in(submitted_password, repository = User)
    user = repository.first
    user_password = BCrypt::Password.new(user.password_digest)

    user if user_password == submitted_password
  end
end
