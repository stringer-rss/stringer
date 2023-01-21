# frozen_string_literal: true

module ControllerHelpers
  include Rack::Test::Methods

  def app
    Stringer
  end

  alias old_get get
  def get(path, params: {}, env: {})
    old_get(path, params, env.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  alias old_post post
  def post(path, params: {}, env: {})
    old_post(path, params, env.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  alias old_put put
  def put(path, params: {}, env: {})
    old_put(path, params, env.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  alias old_delete delete
  def delete(path, params: {}, env: {})
    old_delete(path, params, env.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  def login_as(user)
    session[:user_id] = user.id
  end

  def session
    @session ||= {}
  end
end
