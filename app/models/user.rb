class User < ActiveRecord::Base

  attr_accessible :setup_complete, :api_key
  
  attr_accessible :superfeedr_host, :superfeedr_username, :superfeedr_password

  attr_accessible :password, :password_confirmation
  has_secure_password

  def setup_complete?
    setup_complete
  end

  def has_superfeedr?
   	superfeedr_host != nil && superfeedr_username != nil && superfeedr_password != nil 
  end
end