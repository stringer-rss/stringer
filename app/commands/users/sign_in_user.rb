# frozen_string_literal: true

module SignInUser
  def self.call(submitted_password)
    user = User.first
    user_password = BCrypt::Password.new(user.password_digest)

    user if user_password == submitted_password
  end
end
