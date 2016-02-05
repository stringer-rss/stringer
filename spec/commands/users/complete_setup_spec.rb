require "spec_helper"

app_require "commands/users/complete_setup"

describe CompleteSetup do
  let(:user) { UserFactory.build }
  it "marks setup as complete" do
    user.should_receive(:save).once

    result = CompleteSetup.complete(user)
    result.setup_complete.should be_true
  end
end
