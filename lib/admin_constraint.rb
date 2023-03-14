# frozen_string_literal: true

class AdminConstraint
  def matches?(request)
    request.session.key?(:user_id) &&
      User.find(request.session[:user_id]).admin?
  end
end
