class User < ActiveRecord::Base
#  attr_accessible :setup_complete, :api_key
#  attr_accessible :password, :password_confirmation
  has_secure_password

  def setup_complete?
    setup_complete
  end
end
