# frozen_string_literal: true

class APIKeysController < ApplicationController
  def update
    authorization.skip

    current_user.regenerate_api_key
    redirect_to(edit_profile_path, flash: { success: t(".success") })
  end
end
