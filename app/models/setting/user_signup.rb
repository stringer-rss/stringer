# frozen_string_literal: true

class Setting::UserSignup < Setting
  boolean_accessor :data, :enabled, default: false

  validates :enabled, inclusion: { in: [true, false] }

  def self.first
    first_or_create!
  end

  def self.enabled?
    first_or_create!.enabled? || User.none?
  end
end
