# frozen_string_literal: true

require_relative "./application_record"

class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_key

  has_many :feeds, dependent: :delete_all
  has_many :groups, dependent: :delete_all

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validate :password_challenge_matches

  attr_accessor :password_challenge

  # `password_challenge` logic should be able to be removed in Rails 7.1
  # https://blog.appsignal.com/2023/02/15/whats-new-in-rails-7-1.html#password-challenge-via-has_secure_password
  def password_challenge_matches
    return unless password_challenge

    digested_password = BCrypt::Password.new(password_digest_was)
    return if digested_password.is_password?(password_challenge)

    errors.add(:original_password, "does not match")
  end
end
