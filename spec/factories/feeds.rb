# frozen_string_literal: true

FactoryBot.define do
  factory(:feed) do
    user { default_user }

    sequence(:name, 100) { |n| "Feed #{n}" }
    sequence(:url, 100) { |n| "http://exampoo.com/#{n}" }

    trait :with_group do
      group
    end
  end
end
