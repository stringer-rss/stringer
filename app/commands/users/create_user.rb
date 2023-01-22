# frozen_string_literal: true

class CreateUser
  def self.call(password)
    new.call(password)
  end

  def initialize(repository = User)
    @repo = repository
  end

  def call(password)
    @repo.delete_all
    @repo.create(password:, password_confirmation: password)
  end
end
