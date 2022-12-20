FactoryBot.define do
  factory(:story) do
    feed

    sequence(:entry_id, 100) { |n| "entry-#{n}" }

    trait :read do
      is_read { true }
    end

    trait :starred do
      is_starred { true }
    end

    trait :unread do
      is_read { false }
    end
  end
end
