# frozen_string_literal: true

FactoryBot.define do
  factory(:story) do
    feed

    sequence(:entry_id, 100) { |n| "entry-#{n}" }
    sequence(:published, 100) { |n| n.days.ago }

    trait :read do
      is_read { true }
    end

    trait :starred do
      is_starred { true }
    end

    trait :with_group do
      feed factory: [:feed, :with_group]
    end
  end
end
