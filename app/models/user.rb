# frozen_string_literal: true

require_relative "./application_record"

class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_key

  has_many :feeds, dependent: :delete_all
  has_many :groups, dependent: :delete_all

  validates :username, presence: true, uniqueness: { case_sensitive: false }
end
