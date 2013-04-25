require_relative "./feed_factory"

class UserFactory
  class FakeUser < OpenStruct; end

  def self.build
    FakeUser.new(
      id: rand(100),
      setup_complete: false)
  end
end