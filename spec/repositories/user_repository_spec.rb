# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "repositories/user_repository"

describe UserRepository do
  describe ".fetch" do
    it "returns nil when given id is nil" do
      expect(UserRepository.fetch(nil)).to be_nil
    end

    it "returns the user for the given id" do
      user = create(:user)

      expect(UserRepository.fetch(user.id)).to eq(user)
    end
  end

  describe ".setup_complete?" do
    it "returns false when there are no users" do
      expect(UserRepository.setup_complete?).to be(false)
    end

    it "returns false when user has not completed setup" do
      create(:user)

      expect(UserRepository.setup_complete?).to be(false)
    end

    it "returns true when user has completed setup" do
      create(:user, :setup_complete)

      expect(UserRepository.setup_complete?).to be(true)
    end
  end

  describe ".save" do
    it "saves the given user" do
      user = build(:user)

      expect { UserRepository.save(user) }
        .to change(user, :persisted?).from(false).to(true)
    end

    it "returns the given user" do
      user = User.new

      expect(UserRepository.save(user)).to eq(user)
    end
  end

  describe ".first" do
    it "returns the first user" do
      user = create(:user)
      create(:user)

      expect(UserRepository.first).to eq(user)
    end
  end
end
