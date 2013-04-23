require_relative "../models/user"

class UserRepository
  def self.any?
    User.any?
  end
end