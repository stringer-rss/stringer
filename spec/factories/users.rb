module Factories
  def create_user(params = {})
    build_user(params).tap(&:save!)
  end

  def build_user(params = {})
    User.new(password: "super-secret", **params)
  end
end
