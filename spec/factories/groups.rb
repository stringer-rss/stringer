module Factories
  def create_group(params = {})
    build_group(params).tap(&:save!)
  end

  def build_group(params = {})
    Group.new(**params)
  end
end
