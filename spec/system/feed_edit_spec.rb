# frozen_string_literal: true

RSpec.describe "feeds/edit" do
  def visit_edit_feed
    feed = create(:feed)
    visit("/feeds/#{feed.id}/edit")
  end

  it "does not show a group selector when the user has no groups" do
    login_as(default_user)
    visit_edit_feed

    expect(page).to have_no_select("group-id")
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

  it "pre-selects the feed's current group in the dropdown" do
    login_as(default_user)
    feed = create(:feed, :with_group)
    a11y_skip = [
      "aria-required-children",
      "color-contrast",
      "label",
      "landmark-one-main",
      "page-has-heading-one",
      "region",
      "select-name"
    ]
    visit("/feeds/#{feed.id}/edit", a11y_skip:)

    expect(page).to have_select("group-id", selected: feed.group.name)
  end

  it "allows removing a group from a feed" do
    login_as(default_user)
    feed = create(:feed, :with_group)
    a11y_skip = [
      "aria-required-children",
      "color-contrast",
      "label",
      "landmark-one-main",
      "page-has-heading-one",
      "region",
      "select-name"
    ]
    visit("/feeds/#{feed.id}/edit", a11y_skip:)

    select("", from: "group-id")
    click_on("Save")

    expect(feed.reload.group).to be_nil
  end

  it "allows assigning a feed to a group" do
    login_as(default_user)
    group = create(:group)
    feed = create(:feed)
    a11y_skip = [
      "aria-required-children",
      "color-contrast",
      "label",
      "landmark-one-main",
      "page-has-heading-one",
      "region",
      "select-name"
    ]
    visit("/feeds/#{feed.id}/edit", a11y_skip:)

    select(group.name, from: "group-id")
    click_on("Save")

    expect(feed.reload.group).to eq(group)
  end
end
