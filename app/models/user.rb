# frozen_string_literal: true

require_relative "./application_record"

class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_key
end
