# frozen_string_literal: true

RSpec.describe "heroku setup" do
  it "displays the heroku setup page without authentication" do
    visit("/heroku")

    expect(page).to have_content("One more thing")
  end

  it "displays the scheduler task instructions" do
    visit("/heroku")

    expect(page).to have_content("rake lazy_fetch")
  end

  it "links to the home page" do
    visit("/heroku")

    expect(page).to have_link("Okay, it's ready!", href: "/")
  end
end
