# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    authorization.skip
  end

  def update
    authorization.skip

    setting = Setting.find(params[:id])
    setting.update!(setting_params)

    redirect_to(settings_path)
  end

  private

  def setting_params
    params.expect(setting: [:enabled])
  end
end
