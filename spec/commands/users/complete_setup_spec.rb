require "spec_helper"

app_require "commands/users/complete_setup"

describe CompleteSetup do
  let(:user) { UserFactory.build }
  it "marks setup as complete" do
    expect(user).to receive(:save).once

    result = CompleteSetup.complete(user)
    expect(result.setup_complete).to eq(true)
  end
end
