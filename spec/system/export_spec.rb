# frozen_string_literal: true

RSpec.describe "exporting feeds" do
  it "allows exporting feeds" do
    login_as(default_user)
    feed = create(:feed, :with_group)

    click_on "Export"

    xml = Capybara.string(Downloads.content_for(page, "stringer.opml"))
    expect(xml).to have_css("outline[title='#{feed.name}']")
  end
end
