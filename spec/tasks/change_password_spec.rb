# frozen_string_literal: true

require "spec_helper"

app_require "tasks/change_password"

describe ChangePassword do
  let(:command) { instance_double(ChangeUserPassword) }

  describe "#change_password" do
    it "invokes command with confirmed password" do
      output = StringIO.new
      input = StringIO.new("new-pw\nnew-pw\n")
      task = described_class.new(command, output:, input:)

      expect(command).to receive(:change_user_password).with("new-pw")

      task.change_password
    end

    it "repeats until a matching confirmation" do
      output = StringIO.new
      input = StringIO.new("woops\nnope\nnew-pw\nnew-pw\n")
      task = described_class.new(command, output:, input:)

      expect(command).to receive(:change_user_password).with("new-pw")

      task.change_password
    end
  end
end
