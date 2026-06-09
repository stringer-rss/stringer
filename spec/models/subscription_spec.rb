# frozen_string_literal: true

RSpec.describe Subscription do
  it "has a valid factory" do
    expect(create(:subscription)).to be_valid
  end

  it "belongs to a user" do
    expect(build(:subscription)).to belong_to(:user)
  end

  it "validates presence of user_id" do
    expect(build(:subscription)).to validate_presence_of(:user_id)
  end

  it "validates uniqueness of user_id" do
    expect(create(:subscription)).to validate_uniqueness_of(:user_id)
  end

  it "validates presence of stripe_customer_id" do
    expect(build(:subscription)).to validate_presence_of(:stripe_customer_id)
  end

  it "validates uniqueness of stripe_customer_id" do
    expect(create(:subscription)).to validate_uniqueness_of(:stripe_customer_id)
  end

  it "validates presence of stripe_subscription_id" do
    expect(build(:subscription))
      .to validate_presence_of(:stripe_subscription_id)
  end

  it "validates uniqueness of stripe_subscription_id" do
    expect(create(:subscription))
      .to validate_uniqueness_of(:stripe_subscription_id)
  end

  it "validates presence of status" do
    expect(build(:subscription)).to validate_presence_of(:status)
  end

  it "validates status is one of STATUSES" do
    expect(build(:subscription))
      .to validate_inclusion_of(:status).in_array(described_class::STATUSES)
  end

  it "validates presence of current_period_start" do
    expect(build(:subscription)).to validate_presence_of(:current_period_start)
  end

  it "validates presence of current_period_end" do
    expect(build(:subscription)).to validate_presence_of(:current_period_end)
  end
end
