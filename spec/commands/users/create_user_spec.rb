# frozen_string_literal: true

RSpec.describe CreateUser do
  describe "#call" do
    it "creates a user with the password supplied" do
      expect(User).to receive(:create)

      described_class.call("password")
    end
  end
end
