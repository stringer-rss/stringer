# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Sinatra::AuthenticationHelpers
  helper_method :current_user

  before_action :append_view_path

  # needed for Sinatra
  def append_view_path
    super("./app/views")
  end

  def flash
    session["flash"]
  end
  helper_method :flash
end
