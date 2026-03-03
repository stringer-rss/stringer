# frozen_string_literal: true

RSpec.describe "starred" do
  it "displays starred stories" do
    login_as(default_user)
    create(:story, :starred, title: "Fave Story")

    visit(starred_path)

    expect(page).to have_content("Fave Story")
  end

  it "shows a message when no stories are starred" do
    login_as(default_user)

    visit(starred_path)

    expect(page).to have_content("you haven't starred any stories")
  end
end
