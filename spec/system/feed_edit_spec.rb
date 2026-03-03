# frozen_string_literal: true

RSpec.describe "feeds/edit" do
  def visit_edit_feed
    feed = create(:feed)
    visit("/feeds/#{feed.id}/edit")
  end

  it "allows updating a feed name" do
    login_as(default_user)
    visit_edit_feed

    fill_in("Feed Name", with: "New Name")
    click_on("Save")

    expect(page).to have_content("Updated the feed")
  end

  it "allows updating a feed URL" do
    login_as(default_user)
    visit_edit_feed

    fill_in("Feed URL", with: "http://new.example.com")
    click_on("Save")

    expect(page).to have_content("Updated the feed")
  end
end
