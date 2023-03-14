# frozen_string_literal: true

module CreateUser
  def self.call(password)
    User.create(
      admin: User.none?,
      username: "stringer",
      password:,
      password_confirmation: password
    )
  end
end
