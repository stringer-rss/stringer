require "spec_helper"

app_require "tasks/change_password"

describe ChangePassword do
  let(:command) { double("command") }
  let(:new_password) { "new-pw" }

  let(:task) { ChangePassword.new(command) }

  describe "#change_password" do
    it "invokes command with confirmed password" do
      expect(task).to receive(:ask_hidden).twice
        .and_return(new_password, new_password)

      expect(command)
        .to receive(:change_user_password)
        .with(new_password)

      task.change_password
    end

    it "repeats until a matching confirmation" do
      expect(task).to receive(:ask_hidden).exactly(2).times
        .and_return(new_password, "", new_password, new_password)

      expect(command)
        .to receive(:change_user_password)
        .with(new_password)

      task.change_password
    end
  end
end
