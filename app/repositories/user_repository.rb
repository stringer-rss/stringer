require_relative "../models/user"

class UserRepository
  def self.fetch(id)
    begin
    return nil unless id
    
    User.find(id)

    rescue Exception => msg  
      puts msg
    end 

  end

  def self.setup_complete?
    User.any? && User.first.setup_complete?
  end

  def self.get
  	User.any? && User.first
  end

  def self.fetch_by_superfeedr_username(superfeedr_username)
    User.where(superfeedr_username: superfeedr_username).first
  end

  def self.has_superfeedr()
    User.any? && User.first.has_superfeedr?
  end

  def self.save(user)
    user.save
    user
  end

  def self.first
    User.first
  end
end