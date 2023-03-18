# frozen_string_literal: true

module SignInUser
  def self.call(username, submitted_password)
    user = User.find_by(username:)
    return unless user

    user_password = BCrypt::Password.new(user.password_digest)

    user if user_password == submitted_password
  end
end
