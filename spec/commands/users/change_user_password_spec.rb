require "spec_helper"
require "support/active_record"

app_require "commands/users/change_user_password"

describe ChangeUserPassword do
  let(:repo) { double }
  let(:user) { User.create(password: old_password) }

  let(:old_password) { "old-pw" }
  let(:new_password) { "new-pw" }

  describe "#change_user_password" do
    it "changes the password of the user" do
      expect(repo).to receive(:first).and_return(user)
      expect(repo).to receive(:save)

      command = ChangeUserPassword.new(repo)
      result = command.change_user_password(new_password)

      expect(BCrypt::Password.new(result.password_digest)).to eq new_password
    end

    it "changes the API key of the user" do
      expect(repo).to receive(:first).and_return(user)
      expect(repo).to receive(:save)

      command = ChangeUserPassword.new(repo)
      result = command.change_user_password(new_password)

      expect(result.api_key).to eq ApiKey.compute(new_password)
    end
  end
end
