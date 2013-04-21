require "sinatra/base"

module Sinatra
  module AuthenticationHelpers
    def is_authenticated?
      session[:user_id]
    end

    def needs_authentication?(path)
      return false if ENV['RACK_ENV'] == 'test'
      return false if path == "/login" || path == "/logout"
      true
    end
  end
end