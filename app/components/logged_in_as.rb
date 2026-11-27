# frozen_string_literal: true

class Components::LoggedInAs < Components::Base
  def view_template
    div do
      plain("Logged in as ")
      link_to(current_user.username, edit_profile_path)
    end
  end
end
