require "spec_helper"

app_require "commands/users/superfeedr_user"

describe SuperfeedrUser do
  let(:user) { UserFactory.build }
  it "user with superfeedr" do
    user.should_receive(:save).once

    result = SuperfeedrUser.complete(user)
  end
end