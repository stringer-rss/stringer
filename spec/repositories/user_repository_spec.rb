# frozen_string_literal: true

RSpec.describe UserRepository do
  describe ".fetch" do
    it "returns nil when given id is nil" do
      expect(described_class.fetch(nil)).to be_nil
    end

    it "returns the user for the given id" do
      user = default_user

      expect(described_class.fetch(user.id)).to eq(user)
    end
  end

  describe ".setup_complete?" do
    it "returns false when there are no users" do
      expect(described_class.setup_complete?).to be(false)
    end

    it "returns true when there is at least one user" do
      create(:user)

      expect(described_class.setup_complete?).to be(true)
    end
  end

  describe ".save" do
    it "saves the given user" do
      user = build(:user)

      expect { described_class.save(user) }
        .to change(user, :persisted?).from(false).to(true)
    end

    it "returns the given user" do
      user = User.new

      expect(described_class.save(user)).to eq(user)
    end
  end

  describe ".first" do
    it "returns the first user" do
      user = default_user
      create(:user)

      expect(described_class.first).to eq(user)
    end
  end
end
