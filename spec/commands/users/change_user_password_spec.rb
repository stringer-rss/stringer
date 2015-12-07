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
      repo.should_receive(:first).and_return(user)
      repo.should_receive(:save)

      command = ChangeUserPassword.new(repo)
      result = command.change_user_password(new_password)

      BCrypt::Password.new(result.password_digest).should eq new_password
    end

    it "changes the API key of the user" do
      repo.should_receive(:first).and_return(user)
      repo.should_receive(:save)

      command = ChangeUserPassword.new(repo)
      result = command.change_user_password(new_password)

      result.api_key.should eq ApiKey.compute(new_password)
    end
  end
end
