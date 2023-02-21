# frozen_string_literal: true

describe CreateUser do
  describe "#call" do
    it "removes existing users and create a user with the password supplied" do
      expect(User).to receive(:create)
      expect(User).to receive(:delete_all)

      described_class.call("password")
    end
  end
end
