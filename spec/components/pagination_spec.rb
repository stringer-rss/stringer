# frozen_string_literal: true

RSpec.describe Components::Pagination do
  def render_page(page, total)
    stories = WillPaginate::Collection.create(page, 20, total) { |p| p.replace([]) }
    html = ApplicationController.render(
      described_class.new(stories:, scope: "archive"),
      layout: false
    )
    Capybara.string(html)
  end

  it "links to the next page when there are more pages" do
    expect(render_page(1, 21)).to have_link("Next", href: "?page=2")
  end

  it "links to the previous page when past the first page" do
    expect(render_page(2, 21)).to have_link("Previous", href: "?page=1")
  end

  it "shows the current page out of the total" do
    expect(render_page(2, 50)).to have_text("2 of 3")
  end

  it "shows no links or page count for a single page" do
    expect(render_page(1, 5)).to have_no_css("#pagination *")
      .and have_no_text("of")
  end
end
