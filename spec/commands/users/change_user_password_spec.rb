# frozen_string_literal: true

RSpec.describe ChangeUserPassword do
  let(:repo) { double }
  let(:user) { create(:user, password: old_password) }

  let(:old_password) { "old-pw" }
  let(:new_password) { "new-pw" }

  describe "#change_user_password" do
    it "changes the password of the user" do
      expect(repo).to receive(:first).and_return(user)
      expect(repo).to receive(:save)

      command = described_class.new(repo)
      result = command.change_user_password(new_password)

      expect(BCrypt::Password.new(result.password_digest)).to eq(new_password)
    end

    it "changes the API key of the user" do
      expect(repo).to receive(:first).and_return(user)
      expect(repo).to receive(:save)

      command = described_class.new(repo)
      expect  { command.change_user_password(new_password) }
        .to change(user, :api_key)
    end
  end
end
