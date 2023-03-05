# frozen_string_literal: true

RSpec.describe SignInUser do
  it "returns the user if the password is valid" do
    result = described_class.call(default_user.password)

    expect(result).to eq(default_user)
  end

  it "returns nil if password is invalid" do
    create(:user)

    result = described_class.call("not-the-pw")

    expect(result).to be_nil
  end
end
