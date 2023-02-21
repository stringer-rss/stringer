# frozen_string_literal: true

describe SignInUser do
  let(:valid_password) { "valid-pw" }
  let(:repo) { double(first: user) }

  let(:user) do
    double(password_digest: BCrypt::Password.create(valid_password), id: 1)
  end

  describe "#sign_in" do
    it "returns the user if the password is valid" do
      result = described_class.sign_in(valid_password, repo)

      expect(result.id).to eq(1)
    end

    it "returns nil if password is invalid" do
      result = described_class.sign_in("not-the-pw", repo)

      expect(result).to be_nil
    end
  end
end
