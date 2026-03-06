# frozen_string_literal: true

RSpec.describe "authentication" do
  it "redirects to login when accessing a protected page while logged out" do
    create(:user)

    visit(news_path)

    expect(page).to have_current_path(login_path)
  end
end
