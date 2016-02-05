class CompleteSetup
  def self.complete(user)
    user.setup_complete = true
    user.save
    user
  end
end
