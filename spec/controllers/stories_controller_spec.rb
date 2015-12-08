require "spec_helper"
require 'will_paginate/array'

app_require "controllers/stories_controller"

describe "StoriesController" do
  let(:story_one) { StoryFactory.build }
  let(:story_two) { StoryFactory.build }
  let(:stories) { [story_one, story_two] }

  describe "GET /news" do
    before do
      StoryRepository.stub(:unread).and_return(stories)
      UserRepository.stub(fetch: double)
    end

    it "display list of unread stories" do
      get "/news"

      last_response.body.should have_tag("#stories")
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

      page = last_response.body
      page.should have_tag("a", with: { href: "/feeds/export"})
      page.should have_tag("a", with: { href: "/logout"})
      page.should have_tag("a", with: { href: "https://github.com/swanson/stringer"})
    end

    it "displays a zen-like message when there are no unread stories" do
      StoryRepository.stub(:unread).and_return([])

      get "/news"

      last_response.body.should have_tag("#zen")
    end
  end

  describe "GET /archive" do
    let(:read_one) { StoryFactory.build(is_read: true) }
    let(:read_two) { StoryFactory.build(is_read: true) }
    let(:stories) { [read_one, read_two].paginate }
    before { StoryRepository.stub(:read).and_return(stories) }

    it "displays the list of read stories with pagination" do
      get "/archive"

      page = last_response.body
      page.should have_tag("#stories")
      page.should have_tag("div#pagination")
    end
  end

  describe "GET /starred" do
    let(:starred_one) { StoryFactory.build(is_starred: true) }
    let(:starred_two) { StoryFactory.build(is_starred: true) }
    let(:stories) { [starred_one, starred_two].paginate }
    before { StoryRepository.stub(:starred).and_return(stories) }

    it "displays the list of starred stories with pagination" do
      get "/starred"

      page = last_response.body
      page.should have_tag("#stories")
      page.should have_tag("div#pagination")
    end
  end

  describe "PUT /stories/:id" do
    before { StoryRepository.stub(:fetch).and_return(story_one) }
    context "is_read parameter" do
      context "when it is not malformed" do
        it "marks a story as read" do
          StoryRepository.should_receive(:save).once

          put "/stories/#{story_one.id}", {is_read: true}.to_json

          story_one.is_read.should eq true
        end
      end

      context "when it is malformed" do
        it "marks a story as read" do
          StoryRepository.should_receive(:save).once

          put "/stories/#{story_one.id}", {is_read: "malformed"}.to_json

          story_one.is_read.should eq true
        end
      end
    end

    context "keep_unread parameter" do
      context "when it is not malformed" do
        it "marks a story as permanently unread" do
          put "/stories/#{story_one.id}", {keep_unread: false}.to_json

          story_one.keep_unread.should eq false
        end
      end

      context "when it is malformed" do
        it "marks a story as permanently unread" do
          put "/stories/#{story_one.id}", {keep_unread: "malformed"}.to_json

          story_one.keep_unread.should eq true
        end
      end
    end

    context "is_starred parameter" do
      context "when it is not malformed" do
        it "marks a story as permanently starred" do
          put "/stories/#{story_one.id}", {is_starred: true}.to_json

          story_one.is_starred.should eq true
        end
      end

      context "when it is malformed" do
        it "marks a story as permanently starred" do
          put "/stories/#{story_one.id}", {is_starred: "malformed"}.to_json

          story_one.is_starred.should eq true
        end
      end
    end
  end

  describe "POST /stories/mark_all_as_read" do
    it "marks all unread stories as read and reload the page" do
      MarkAllAsRead.any_instance.should_receive(:mark_as_read).once

      post "/stories/mark_all_as_read", story_ids: ["1", "2", "3"]

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/news"
    end
  end

  describe "GET /feed/:feed_id" do
    it "looks for a particular feed" do
      FeedRepository.should_receive(:fetch).with(story_one.feed.id.to_s).and_return(story_one.feed)
      StoryRepository.should_receive(:feed).with(story_one.feed.id.to_s).and_return([story_one])

      get "/feed/#{story_one.feed.id}"
    end

    it "displays a list of stories" do
      FeedRepository.stub(:fetch).and_return(story_one.feed)
      StoryRepository.stub(:feed).and_return(stories)

      get "/feed/#{story_one.feed.id}"

      last_response.body.should have_tag("#stories")
    end

    it "differentiates between read and unread" do
      FeedRepository.stub(:fetch).and_return(story_one.feed)
      StoryRepository.stub(:feed).and_return(stories)

      story_one.is_read = false
      story_two.is_read = true

      get "/feed/#{story_one.feed.id}"

      last_response.body.should have_tag('li', :class => 'story')
      last_response.body.should have_tag('li', :class => 'unread')
    end
  end
end
