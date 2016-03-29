require "sinatra/base"

require_relative "../repositories/user_repository"

module Sinatra
  module AuthenticationHelpers
    def authenticated?
      current_user.present?
    end

    def needs_authentication?(path)
      return false if ENV["RACK_ENV"] == "test" && ENV["FORCE_TEST_AUTH"] != "true"
      return false if %w(/login /logout /heroku /setup/password).include?(path)
      return false if path =~ /css|js|img/
      true
    end

    def needs_setup_complete?(path)
      return false if %w(/setup/tutorial /feeds/import).include?(path)
      true
    end

    def current_user
      UserRepository.fetch(session[:user_id])
    end
  end
end
