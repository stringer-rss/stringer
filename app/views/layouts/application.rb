# frozen_string_literal: true

module Views
  module Layouts
    class Application < Components::Base
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::StylesheetLinkTag
      include Phlex::Rails::Helpers::JavascriptIncludeTag
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::LinkToUnlessCurrent
      include Phlex::Rails::Helpers::Flash

      def view_template
        doctype

        html do
          head do
            title { "YourAppNameHere" }
            csrf_meta_tags
            csp_meta_tag

            stylesheet_link_tag("application", media: "all")
            javascript_include_tag("application")
          end

          action = "keydown@document->hotkeys#handleKeydown"
          body(data: { controller: "hotkeys", action: }) do
            if current_user.logged_in?
              plain(current_user.email)
              link_to("Account", account_path)
              button_to("Log Out", session_path, method: :delete)
            else
              link_to_unless_current("Log In", new_session_path)
              link_to_unless_current("Sign Up", new_account_path)
            end

            div(class: "flashes") do
              flash.each do |type, message|
                div(class: "flash-#{type}") { message }
              end
            end

            yield
          end
        end
      end
    end
  end
end
