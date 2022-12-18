# frozen_string_literal: true

module Sinatra
  module ControllerHelpers
    def rails_route(method, path, options)
      options = options.with_indifferent_access
      to = options.delete(:to)
      controller_name, action_name = to.split("#")
      controller_klass = "#{controller_name.camelize}Controller".constantize
      route(method.to_s.upcase, path, options) do
        # Make sure that our parsed URL params are where Rack (and ActionDispatch) expect them
        app = controller_klass.action(action_name)
        app.call(request.env.merge("rack.request.query_hash" => params))
      end
    end
  end
end
