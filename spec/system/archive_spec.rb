# frozen_string_literal: true

RSpec.describe "archive" do
  def create_read_stories(count)
    count.times { create(:story, :read) }
  end

  it "displays read stories" do
    login_as(default_user)
    create(:story, :read, title: "Old Story")

    visit(archive_path)

    expect(page).to have_content("Old Story")
  end

  it "shows a message when no stories have been read" do
    login_as(default_user)

    visit(archive_path)

    expect(page).to have_content("you haven't read any stories")
  end

  it "paginates read stories" do
    login_as(default_user)
    create_read_stories(21)

    visit(archive_path)

    expect(page).to have_link("Next")
  end
end
