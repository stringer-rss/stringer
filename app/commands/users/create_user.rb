# frozen_string_literal: true

require_relative "../../utils/api_key"

class CreateUser
  def initialize(repository = User)
    @repo = repository
  end

  def call(password)
    @repo.delete_all
    @repo.create(
      password: password,
      password_confirmation: password,
      setup_complete: false,
      api_key: ApiKey.compute(password)
    )
  end
end
