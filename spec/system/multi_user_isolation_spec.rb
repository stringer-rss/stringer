# frozen_string_literal: true

RSpec.describe "multi-user data isolation" do
  it "does not show another user's stories on the news page" do
    create(:story, feed: create(:feed, user: create(:user)))
    login_as(default_user)

    visit(news_path)

    expect(page).to have_content("You've reached RSS Zero")
  end

  it "does not show another user's starred stories" do
    create(:story, :starred, feed: create(:feed, user: create(:user)))
    login_as(default_user)

    visit(starred_path)

    expect(page).to have_content("you haven't starred any stories")
  end

  it "does not show another user's read stories in the archive" do
    create(:story, :read, feed: create(:feed, user: create(:user)))
    login_as(default_user)

    visit(archive_path)

    expect(page).to have_content("you haven't read any stories")
  end

  it "does not show another user's feeds on the feeds page" do
    create(:feed, user: create(:user))
    login_as(default_user)

    visit(feeds_path)

    expect(page).to have_content("Hey, you should add some feeds")
  end
end
