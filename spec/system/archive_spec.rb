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

  it "navigates to the next page", :aggregate_failures do
    login_as(default_user)
    create_read_stories(21)
    visit(archive_path)

    click_on("Next")

    expect(page).to have_content("2 of 2")
    expect(page).to have_link("Previous")
  end

  it "navigates pages with arrow keys", :aggregate_failures do
    login_as(default_user)
    create_read_stories(21)
    visit(archive_path)

    send_keys(:arrow_right)
    expect(page).to have_link("Previous")

    send_keys(:arrow_left)
    expect(page).to have_link("Next")
    expect(page).to have_no_link("Previous")
  end
end
