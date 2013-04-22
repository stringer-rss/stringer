require_relative "../../models/user"

class SignInUser
  def self.sign_in(email, password, repository = User)
    user = repository.where(email: email).first

    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end
end