# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    authorization.skip
    render(Views::Settings::Index.new(setting: Setting::UserSignup.first))
  end

  def update
    authorization.skip

    setting = Setting.find(params.expect(:id))
    setting.update!(setting_params)

    redirect_to(settings_path)
  end

  private

  def setting_params
    params.expect(setting: [:enabled])
  end
end
