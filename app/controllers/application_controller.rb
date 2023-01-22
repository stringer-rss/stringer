# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :append_view_path
  before_action :complete_setup
  before_action :authenticate_user
  after_action :rotate_flash

  private

  # needed for Sinatra
  def append_view_path
    super("./app/views")
  end

  def complete_setup
    redirect_to("/setup/password") unless UserRepository.setup_complete?
  end

  def flash
    @flash ||= Sinatra::Flash::FlashHash.new(session[:flash])
  end
  helper_method :flash

  def rotate_flash
    session[:flash] = flash.next # for Sinatra
  end

  def authenticate_user
    return if current_user

    session[:redirect_to] = request.fullpath
    redirect_to("/login")
  end

  def current_user
    UserRepository.fetch(session[:user_id])
  end
  helper_method :current_user
end
