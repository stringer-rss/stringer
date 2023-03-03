# frozen_string_literal: true

RSpec.describe User do
  describe "#update_api_key" do
    it "updates the api key when the username changed" do
      user = create(:user, username: "stringer", password: "super-secret")
      user.update!(username: "booger")

      expect(user.api_key).to eq(Digest::MD5.hexdigest("booger:super-secret"))
    end

    it "updates the api key when the password changed" do
      user = create(:user, username: "stringer", password: "super-secret")
      user.update!(password: "new-password")

      expect(user.api_key).to eq(Digest::MD5.hexdigest("stringer:new-password"))
    end

    it "does nothing when the username and password have not changed" do
      user = create(:user, username: "stringer", password: "super-secret")
      user = described_class.find(user.id)

      expect { user.save! }.to not_change(user, :api_key).and not_raise_error
    end

    it "raises an error when password and password challenge are blank" do
      user = create(:user, username: "stringer", password: "super-secret")
      user = described_class.find(user.id)
      expected_message = "Cannot change username without providing a password"

      expect { user.update!(username: "booger") }
        .to raise_error(ActiveRecord::ActiveRecordError, expected_message)
    end
  end
end
