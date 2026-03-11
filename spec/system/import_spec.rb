# frozen_string_literal: true

RSpec.describe "importing feeds" do
  it "allows skipping the import" do
    login_as(default_user)
    visit(feeds_import_path)

    click_on("Not now")

    expect(page).to have_content("We're getting you some stories to read")
  end

  it "allows importing feeds" do
    login_as(default_user)
    visit(feeds_import_path)
    file_path = Rails.root.join("spec/fixtures/feeds.opml")

    attach_file("opml_file", file_path, visible: false)

    expect(page).to have_content("We're getting you some stories to read")
  end

  it "gracefully handles an invalid OPML file" do
    login_as(default_user)
    visit(feeds_import_path)
    file_path = Rails.root.join("spec/fixtures/invalid.opml")

    attach_file("opml_file", file_path, visible: false)

    expect(page).to have_content("We're getting you some stories to read")
  end

  def import_grouped_opml
    file_path = Rails.root.join("spec/fixtures/feeds.opml")
    attach_file("opml_file", file_path, visible: false)
    expect(page).to have_text("We're getting you some stories to read")
  end

  it "creates groups from the OPML structure" do
    login_as(default_user)
    visit(feeds_import_path)

    import_grouped_opml

    group_names = default_user.groups.pluck(:name)
    expect(group_names).to include("Football News", "RoR")
  end

  it "assigns imported feeds to their groups" do
    login_as(default_user)
    visit(feeds_import_path)

    import_grouped_opml

    feed = default_user.feeds.find_by!(name: "TMW Football Transfer News")
    expect(feed.group.name).to eq("Football News")
  end

  it "imports ungrouped feeds without a group" do
    login_as(default_user)
    visit(feeds_import_path)

    import_grouped_opml

    feed = default_user.feeds.find_by!(name: "Autoblog")
    expect(feed.group).to be_nil
  end
end
