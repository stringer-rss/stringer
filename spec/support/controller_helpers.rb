# frozen_string_literal: true

module ControllerHelpers
  include Rack::Test::Methods

  def app
    Stringer
  end

  def session
    last_request.env["rack.session"]
  end
end
