require "sinatra/base"

require_relative "../repositories/user_repository"

module Sinatra
  module AuthenticationHelpers
    def is_authenticated?
      session[:user_id]
    end

    def needs_authentication?(path)
      return false if ENV['RACK_ENV'] == 'test'
      return false if !UserRepository.setup_complete?
      return false if path == "/login" || path == "/logout"
      return false if path =~ /css/ || path =~ /js/ || path =~ /img/
      true
    end

    def current_user
      UserRepository.fetch(session[:user_id])
    end
  end
end