# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:username, 100) { |n| "user-#{n}" }
    password { "super-secret" }
    admin { false }
  end
end
