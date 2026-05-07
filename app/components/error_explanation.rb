# frozen_string_literal: true

module Components
  class ErrorExplanation < Components::Base
    attr_accessor :errors

    def initialize(errors:)
      super()
      self.errors = errors
    end

    def view_template
      return if errors.none?

      div(class: "error-explanation") do
        h2 { "Something went wrong" }
        ul do
          errors.full_messages.each { |message| li { message } }
        end
      end
    end
  end
end
