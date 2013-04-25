require_relative "../models/user"

class UserRepository
  def self.fetch(id)
    User.find(id)
  end

  def self.setup_complete?
    User.any? && User.first.setup_complete?
  end
end