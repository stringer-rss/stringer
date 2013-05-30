require_relative "../../models/user"

class SetupSuperfeedr

  def self.add(host, username, password, repository = User)
	begin
	  	user = repository.first
	  	#return false unless user
	  	user.superfeedr_host = host
	  	user.superfeedr_username = username
	  	user.superfeedr_password = password
	  	user.save
  	rescue Exception => msg  
		#puts msg
		return nil
	end	
  	
  end

  def self.remove(username, repository = User)
  	begin
  		user = UserRepository.fetch_by_superfeedr_username(username)
	  	return nil unless user
	  	user.superfeedr_host = nil
		user.superfeedr_username = nil
		user.superfeedr_password = nil
		user.save
	rescue Exception => msg  
		#puts msg
		return nil
	end	
  end

end