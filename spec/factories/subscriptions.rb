# frozen_string_literal: true

FactoryBot.define do
  factory(:subscription) do
    user

    sequence(:stripe_customer_id, 100) { |n| "cus_#{n}" }
    sequence(:stripe_subscription_id, 100) { |n| "sub_#{n}" }
    status { "active" }
    current_period_start { Time.current }
    current_period_end { 1.month.from_now }
  end
end
