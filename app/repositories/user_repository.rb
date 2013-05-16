require_relative "../models/user"

class UserRepository
  def self.fetch(id)
    return nil unless id
    
    User.find(id)
  end

  def self.setup_complete?
    User.any? && User.first.setup_complete?
  end

  def self.save(user)
    user.save
    user
  end

  def self.first
    User.first
  end
end