# frozen_string_literal: true

RSpec.describe CreateUser do
  it "creates a user with the password supplied" do
    user = described_class.call("my-password")

    expect(user.password).to eq("my-password")
  end

  it "makes the first user an admin" do
    user = described_class.call("my-password")

    expect(user).to be_admin
  end

  it "makes users after the first non-admin" do
    create(:user)

    user = described_class.call("my-password")

    expect(user).not_to be_admin
  end
end
