# frozen_string_literal: true

FactoryBot.define do
  factory(:group) { sequence(:name, 100) { |n| "Group #{n}" } }
end
