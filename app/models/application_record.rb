# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def error_messages
    errors.full_messages.join(", ")
  end
end
