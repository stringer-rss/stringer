# frozen_string_literal: true

class FeverController < ApplicationController
  skip_before_action :complete_setup, only: [:index, :update]
  protect_from_forgery with: :null_session, only: [:update]

  def index
    authorization.skip
    render(json: FeverAPI::Response.call(fever_params))
  end

  def update
    authorization.skip
    render(json: FeverAPI::Response.call(fever_params))
  end

  private

  def fever_params
    params.permit(FeverAPI::PARAMS).to_hash.symbolize_keys.merge(authorization:)
  end

  def authenticate_user
    return if current_user

    render(json: { api_version: FeverAPI::API_VERSION, auth: 0 })
  end

  def current_user
    if instance_variable_defined?(:@current_user)
      @current_user
    else
      @current_user = User.find_by(api_key: params[:api_key])
    end
  end
end
