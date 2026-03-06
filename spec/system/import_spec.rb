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
end
