class SuperfeedrUser
  def self.complete(user)
  	user.superfeedr_host = "localhost"
    user.superfeedr_username = "demo"
    user.superfeedr_password = "demo"
    user.save
    user
  end
end