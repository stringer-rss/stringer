require_relative "../../models/user"

class SignInUser
  def self.sign_in(submitted_password, repository = User)
    user = repository.first
    user_password = BCrypt::Password.new(user.password_digest)

    if user_password == submitted_password
      user
    else
      nil
    end
  end
end