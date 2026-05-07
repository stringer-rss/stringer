# frozen_string_literal: true

module Views
  module Accounts
    class New < Views::Base
      attr_accessor :user

      def initialize(user:)
        super()
        self.user = user
      end

      def view_template
        h1 { "New Account" }

        form_with(model: user, url: account_path) do |form|
          render(Components::ErrorExplanation.new(errors: user.errors))

          div(class: "field") do
            form.label(:email)
            form.email_field(:email, required: true)
          end

          div(class: "field") do
            form.label(:password)
            form.password_field(:password, required: true)
          end

          div(class: "field") do
            form.label(:password_confirmation)
            form.password_field(:password_confirmation, required: true)
          end

          div(class: "actions") do
            form.submit("Create Account")
          end
        end
      end
    end
  end
end
