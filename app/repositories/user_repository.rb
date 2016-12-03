require_relative "../models/user"

class UserRepository
  def self.fetch(id)
    return nil unless id

    User.find_by_id(id)
  end

  def self.created?
    User.any?
  end

  def self.setup_complete?
    self.created? && User.first.setup_complete?
  end

  def self.save(user)
    user.save
    user
  end
end
