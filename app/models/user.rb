class User < ActiveRecord::Base
  has_secure_password

  def setup_complete?
    setup_complete
  end
end
