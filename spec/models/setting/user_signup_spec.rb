# frozen_string_literal: true

RSpec.describe Setting::UserSignup do
  describe ".first" do
    it "returns the first record" do
      setting = described_class.create!

      expect(described_class.first).to eq(setting)
    end

    it "creates a record if one does not already exist" do
      expect { described_class.first }.to change(described_class, :count).by(1)
    end
  end

  describe ".enabled?" do
    it "returns true when enabled" do
      create(:user)
      described_class.create!(enabled: true)

      expect(described_class.enabled?).to be(true)
    end

    it "returns false when disabled" do
      create(:user)
      described_class.create!(enabled: false)

      expect(described_class.enabled?).to be(false)
    end

    it "returns true when no users exist" do
      described_class.create!(enabled: false)

      expect(described_class.enabled?).to be(true)
    end
  end
end
