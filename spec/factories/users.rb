module Factories
  USER_TRAITS = {
    setup_complete: -> { { setup_complete: true } }
  }.freeze

  def create_user(*traits, **params)
    build_user(*traits, **params).tap(&:save!)
  end

  def build_user(*traits, **params)
    traits.each { |trait| params.merge!(USER_TRAITS.fetch(trait).call) }

    User.new(password: "super-secret", **params)
  end
end
