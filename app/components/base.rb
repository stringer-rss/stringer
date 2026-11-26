# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::T

  register_value_helper :current_user
end
