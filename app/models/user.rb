# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  encrypts :api_key, deterministic: true

  has_many :feeds, dependent: :delete_all
  has_many :groups, dependent: :delete_all

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validate :password_challenge_matches

  before_save :update_api_key

  enum :stories_order, { desc: "desc", asc: "asc" }, prefix: true

  attr_accessor :password_challenge

  # `password_challenge` logic should be able to be removed in Rails 7.1
  # https://blog.appsignal.com/2023/02/15/whats-new-in-rails-7-1.html#password-challenge-via-has_secure_password
  def password_challenge_matches
    return unless password_challenge

    digested_password = BCrypt::Password.new(password_digest_was)
    return if digested_password.is_password?(password_challenge)

    errors.add(:original_password, "does not match")
  end

  def update_api_key
    return unless password_digest_changed? || username_changed?

    if password_challenge.blank? && password.blank?
      message = "Cannot change username without providing a password"

      raise(ActiveRecord::ActiveRecordError, message)
    end

    password = password_challenge.presence || self.password.presence

    # API key based on Fever spec: https://feedafever.com/api
    self.api_key = Digest::MD5.hexdigest("#{username}:#{password}")
  end
end
