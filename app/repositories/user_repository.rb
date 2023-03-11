# frozen_string_literal: true

class UserRepository
  def self.fetch(id)
    return nil unless id

    User.find(id)
  end

  def self.setup_complete?
    User.any?
  end

  def self.save(user)
    user.save
    user
  end

  def self.first
    User.first
  end
end
