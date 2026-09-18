# frozen_string_literal: true

RSpec.describe "GoodJob dashboard" do
  def sign_in_as_admin
    admin = record_double(User, admin?: true, authenticate: true)
    RSpec::Mocks.expect_message(User, :find_by).and_return(admin)

    post(session_path, params: { session: { email: "a@b.com", password: "x" } })
  end

  it "is not found for anonymous visitors" do
    get("/good_job")

    expect(response).to have_http_status(:not_found)
  end

  it "is not found for signed-in non-admins" do
    user = create(:user)
    post(session_path, params: { session: user.slice(:email, :password) })

    get("/good_job")

    expect(response).to have_http_status(:not_found)
  end

  it "renders for admins" do
    sign_in_as_admin

    get("/good_job")
    follow_redirect!

    expect(response).to have_http_status(:ok)
  end
end
