# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.boolean_accessor(attribute, key, default: false)
    store_accessor(attribute, key)

    define_method(key) do
      value = super()
      value.nil? ? default : CastBoolean.call(value)
    end
    alias_method(:"#{key}?", :"#{key}")

    define_method(:"#{key}=") do |value|
      super(value.nil? ? default : CastBoolean.call(value))
    end
  end

  def error_messages
    errors.full_messages.join(", ")
  end
end
