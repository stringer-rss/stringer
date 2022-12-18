# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Sinatra::AuthenticationHelpers
  helper_method :current_user

  before_action :append_view_path
  after_action :rotate_flash

  # needed for Sinatra
  def append_view_path
    super("./app/views")
  end

  def flash
    @flash ||= Sinatra::Flash::FlashHash.new(session[:flash])
  end
  helper_method :flash

  def rotate_flash
    session[:flash] = flash.next # for Sinatra
  end
end
