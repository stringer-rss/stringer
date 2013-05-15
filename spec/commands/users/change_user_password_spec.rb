require "spec_helper"

app_require "commands/users/change_user_password"

describe ChangeUserPassword do
  let(:repo) do
    double("repo")
  end

  let(:user) do
    double("user", id: 1, password_digest: BCrypt::Password.create(old_password))
  end

  let(:old_password){ "old-pw" }
  let(:new_password){ "new-pw" }

  describe "#change_user_password" do
    it "changes the password of the user" do
      command = ChangeUserPassword.new(repo)

      repo.should_receive(:first){ user }
      user.should_receive(:password=).with(new_password)
      user.should_receive(:save)

      command.change_user_password(new_password)
    end
  end
end
