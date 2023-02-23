# frozen_string_literal: true

class Authorization
  attr_accessor :user, :authorized

  class NotAuthorizedError < StandardError; end

  def initialize(user)
    self.user = user
    self.authorized = false
  end

  alias authorized? authorized

  def check(record)
    raise(NotAuthorizedError) unless [nil, user.id].include?(record.user_id)

    self.authorized = true
    record
  end

  def scope(records)
    self.authorized = true
    records.left_joins(:user).where(users: { id: [nil, user.id] })
  end

  def skip
    self.authorized = true
  end

  def verify
    raise(NotAuthorizedError) unless authorized?
  end
end
