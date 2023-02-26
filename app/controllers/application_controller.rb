# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :complete_setup
  before_action :authenticate_user
  after_action -> { authorization.verify }

  private

  def authorization
    @authorization ||= Authorization.new(current_user)
  end

  def complete_setup
    redirect_to("/setup/password") unless UserRepository.setup_complete?
  end

  def authenticate_user
    return if current_user

    session[:redirect_to] = request.fullpath
    redirect_to("/login")
  end

  def current_user
    @current_user ||= UserRepository.fetch(session[:user_id])
  end
  helper_method :current_user
end
