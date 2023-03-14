# frozen_string_literal: true

RSpec.describe AdminConstraint do
  def make_request(session: {})
    request = ActionDispatch::Request.new({})
    request.session = session
    request
  end

  it "matches when the session user is an admin" do
    user = create(:user, admin: true)
    request = make_request(session: { user_id: user.id })

    expect(described_class.new.matches?(request)).to be(true)
  end

  it "does not match when the session user is not an admin" do
    user = create(:user)
    request = make_request(session: { user_id: user.id })

    expect(described_class.new.matches?(request)).to be(false)
  end

  it "does not match when there is no session user" do
    request = make_request

    expect(described_class.new.matches?(request)).to be(false)
  end
end
