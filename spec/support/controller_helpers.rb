# frozen_string_literal: true

module ControllerHelpers
  include Rack::Test::Methods

  class Request
    def headers
      @headers ||= {}
    end
  end

  def app
    Stringer
  end

  def request
    @request ||= Request.new
  end

  alias old_get get
  def get(path, params: {})
    old_get(path, params, request.headers.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  alias old_post post
  def post(path, params: {})
    old_post(path, params, request.headers.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  alias old_put put
  def put(path, params: {})
    old_put(path, params, request.headers.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  alias old_delete delete
  def delete(path, params: {})
    old_delete(path, params, request.headers.merge("rack.session" => session))
    @session = last_request.env["rack.session"]
  end

  def login_as(user)
    session[:user_id] = user.id
  end

  def session
    @session ||= {}
  end
end
