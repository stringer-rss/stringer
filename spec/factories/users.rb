# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    password { "super-secret" }

    trait :setup_complete do
      setup_complete { true }
    end
  end
end
