# frozen_string_literal: true

FactoryBot.define do
  factory(:group) do
    user { default_user }
    sequence(:name, 100) { |n| "Group #{n}" }
  end
end
