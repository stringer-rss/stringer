# frozen_string_literal: true

RSpec.describe "adding a feed" do
  def stub_discovery(url:, title: "My Feed")
    feed = instance_double(Feedjira::Parser::Atom, title:, feed_url: url)
    expect(FeedDiscovery).to receive(:call).with(url).and_return(feed)
  end

  def submit_feed(url)
    visit(feeds_new_path)
    fill_in("Feed URL", with: url)
    click_on("Add")
  end

  it "allows adding a new feed" do
    login_as(default_user)
    stub_discovery(url: "http://example.com/feed.xml")
    expect(CallableJob).to receive(:perform_later)

    submit_feed("http://example.com/feed.xml")

    expect(page).to have_content("We've added your new feed")
  end

  it "shows an error when the feed is not found" do
    login_as(default_user)
    expect(FeedDiscovery).to receive(:call).and_return(false)

    submit_feed("http://example.com/bad")

    expect(page).to have_content("We couldn't find that feed")
  end

  it "shows an error when already subscribed" do
    login_as(default_user)
    url = "http://example.com/feed.xml"
    stub_discovery(url:)
    create(:feed, url:, user: default_user)

    submit_feed(url)

    expect(page).to have_content("You are already subscribed")
  end
end
