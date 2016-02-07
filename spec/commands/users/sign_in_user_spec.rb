require "spec_helper"

app_require "commands/users/sign_in_user"

describe SignInUser do
  let(:valid_password) { "valid-pw" }
  let(:repo) { double(first: user) }

  let(:user) do
    double(password_digest: BCrypt::Password.create(valid_password), id: 1)
  end

  describe "#sign_in" do
    it "returns the user if the password is valid" do
      result = SignInUser.sign_in(valid_password, repo)

      expect(result.id).to eq 1
    end

    it "returns nil if password is invalid" do
      result = SignInUser.sign_in("not-the-pw", repo)

      expect(result).to be_nil
    end
  end
end
