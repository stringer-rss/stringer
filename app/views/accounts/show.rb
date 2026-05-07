# frozen_string_literal: true

module Views
  module Accounts
    class Show < Views::Base
      attr_accessor :user

      def initialize(user:)
        super()
        self.user = user
      end

      def view_template
        h1 { "My Account" }

        form_with(model: user, url: account_path) do |form|
          render(Components::ErrorExplanation.new(errors: user.errors))

          div(class: "field") do
            form.label(:email)
            form.email_field(:email, required: true)
          end

          div(class: "actions") do
            form.submit("Update Account")
          end
        end

        button_to("Delete Account", account_path, method: :delete)
      end
    end
  end
end
