require "spec_helper"

app_require "controllers/stories_controller"

describe "StoriesController" do
  let(:story_one) { StoryFactory.build }
  let(:story_two) { StoryFactory.build }
  let(:stories) { [story_one, story_two] }

  describe "/news" do
    before do
      StoryRepository.stub(:unread).and_return(stories)
      UserRepository.stub(fetch: stub)
    end
    
    it "display list of unread stories" do
      get "/news"

      last_response.body.should have_tag("li.story", count: 2)
    end

    it "displays the blog title and article title" do
      StoryRepository.should_receive(:unread).and_return([story_one])

      get "/news"

      last_response.body.should include(story_one.headline)
      last_response.body.should include(story_one.source)
    end

    it "displays all user actions" do
      get "/news"

      last_response.body.should have_tag("#mark-all")
      last_response.body.should have_tag("#refresh")
      last_response.body.should have_tag("#feeds")
      last_response.body.should have_tag("#add-feed")
    end

    it "should have correct footer links" do
      get "/news"

      content = last_response.body
      content.should have_tag("a", with: { href: "/feeds/export"})
      content.should have_tag("a", with: { href: "/logout"})
      content.should have_tag("a", with: { href: "https://github.com/swanson/stringer"})
    end

    it "displays a zen-like message when there are no unread stories" do
      StoryRepository.stub(:unread).and_return([])

      get "/news"

      last_response.body.should have_tag("#zen")
    end
  end

  describe "/mark_as_read" do
    before { StoryRepository.stub(:fetch).and_return(story_one) }

    it "marks a story as read" do
      StoryRepository.should_receive(:save).once

      post "/mark_as_read", {story_id: story_one.id}.to_json

      story_one.is_read.should be_true
    end
  end

  describe "/mark_all_as_read" do
    it "marks all unread stories as read and reload the page" do
      MarkAllAsRead.any_instance.should_receive(:mark_as_read).once

      post "/mark_all_as_read", story_ids: ["1", "2", "3"]

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"
    end
  end
end