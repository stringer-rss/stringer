require "sinatra/base"

require_relative "../repositories/user_repository"

module Sinatra
  module AuthenticationHelpers
    def authenticated?
      session[:user_id]
    end

    def needs_authentication?(path)
      return false if ENV["RACK_ENV"] == "test"
      return false unless UserRepository.setup_complete?
      return false if %w(/login /logout /heroku).include?(path)
      return false if path =~ /css|js|img/
      true
    end

    def current_user
      UserRepository.fetch(session[:user_id])
    end
  end
end
