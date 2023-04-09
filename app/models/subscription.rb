# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user

  STATUSES = ["active", "past_due", "unpaid", "canceled"].freeze

  validates :user_id, presence: true, uniqueness: true
  validates :stripe_customer_id, presence: true, uniqueness: true
  validates :stripe_subscription_id, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :current_period_start, presence: true
  validates :current_period_end, presence: true
end
