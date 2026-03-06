# frozen_string_literal: true

RSpec.describe "authentication" do
  before { create(:user) }

  it "redirects to login when accessing news while logged out" do
    visit(news_path)

    expect(page).to have_current_path(login_path)
  end

  it "redirects to login when accessing starred while logged out" do
    visit(starred_path)

    expect(page).to have_current_path(login_path)
  end

  it "redirects to login when accessing archive while logged out" do
    visit(archive_path)

    expect(page).to have_current_path(login_path)
  end

  it "redirects to login when accessing feeds while logged out" do
    visit(feeds_path)

    expect(page).to have_current_path(login_path)
  end

  it "redirects to login when accessing a feed while logged out" do
    feed = create(:feed)

    visit("/feed/#{feed.id}")

    expect(page).to have_current_path(login_path)
  end
end
