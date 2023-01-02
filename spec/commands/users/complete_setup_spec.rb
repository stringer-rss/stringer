# frozen_string_literal: true

require "spec_helper"

app_require "commands/users/complete_setup"

describe CompleteSetup do
  let(:user) { build(:user) }

  it "marks setup as complete" do
    expect(user).to receive(:save).once

    result = described_class.complete(user)
    expect(result.setup_complete).to be(true)
  end
end
