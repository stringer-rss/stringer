require_relative "./application_record"

class User < ApplicationRecord
  has_secure_password
end
