require_relative "../../models/user"
require_relative "../../repositories/user_repository"

class SetupSuperfeedr

  def self.add(host, username, password, repository = User)
	user = UserRepository.first
  	return nil unless user
  	user.superfeedr_host = host
  	user.superfeedr_username = username
  	user.superfeedr_password = password
  	user.save
  	user
  end

  def self.remove(username, repository = User)
  	user = repository.fetch_by_superfeedr_username(username)
	return nil unless user
	user.superfeedr_host = nil
	user.superfeedr_username = nil
	user.superfeedr_password = nil
	user.save	
  end
end