# frozen_string_literal: true

module CastBoolean
  TRUE_VALUES = Set.new(["true", true, "1"]).freeze
  FALSE_VALUES = Set.new(["false", false, "0"]).freeze

  def self.call(boolean)
    if (TRUE_VALUES + FALSE_VALUES).exclude?(boolean)
      raise(ArgumentError, "cannot cast to boolean: #{boolean.inspect}")
    end

    TRUE_VALUES.include?(boolean)
  end
end
