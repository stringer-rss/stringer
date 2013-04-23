require "spec_helper"

app_require "commands/users/create_user"

describe CreateUser do
  let(:repo) { stub }

  describe "#create" do
    it "creates a user with the password supplied" do
      command = CreateUser.new(repo)

      repo.should_receive(:create)
      
      command.create("password")
    end
  end
end