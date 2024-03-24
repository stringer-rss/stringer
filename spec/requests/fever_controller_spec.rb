# frozen_string_literal: true

RSpec.describe FeverController do
  def standard_answer
    { api_version: 3, auth: 1, last_refreshed_on_time: 0 }
  end

  def cannot_auth
    { api_version: 3, auth: 0 }
  end

  def response_as_object
    JSON.parse(response.body, symbolize_names: true)
  end

  def params(user: default_user, **overrides)
    { api_key: user.api_key, **overrides }
  end

  describe "authentication" do
    it "authenticates request with correct api_key" do
      get("/fever", params:)

      expect(response_as_object).to include(standard_answer)
    end

    it "does not authenticate request with incorrect api_key" do
      get "/fever", params: params(api_key: "foo")

      expect(response_as_object).to include(cannot_auth)
    end

    it "does not authenticate request when api_key is not provided" do
      create(:user)

      get "/fever", params: params(api_key: nil)

      expect(response_as_object).to include(cannot_auth)
    end
  end

  describe "#get" do
    it "returns standard answer" do
      get("/fever", params:)

      expect(response_as_object).to include(standard_answer)
    end

    context "when 'groups' header is provided" do
      it "returns only ungrouped feedsin the ungrouped group" do
        feed = create(:feed)

        get("/fever", params: params(groups: nil))

        expect_groups_response([Group::UNGROUPED], [feed])
      end

      it "returns only grouped feeds in their respective groups" do
        grouped_feed = create(:feed, :with_group)

        get("/fever", params: params(groups: nil))

        groups = [Group::UNGROUPED, grouped_feed.group]
        expect_groups_response(groups, [grouped_feed])
      end

      it "returns grouped and ungrouped feeds by groups" do
        feed = create(:feed)
        grouped_feed = create(:feed, :with_group)

        get("/fever", params: params(groups: nil))

        groups = [Group::UNGROUPED, grouped_feed.group]
        expect_groups_response(groups, [feed, grouped_feed])
      end

      def expect_groups_response(groups, feeds_groups)
        feeds_groups =
          feeds_groups.map do |feed|
            { group_id: feed.group_id || 0, feed_ids: feed.id.to_s }
          end
        expect(response_as_object).to include(standard_answer)
          .and include(
            groups: match_array(groups.map(&:as_fever_json)),
            feeds_groups: match_array(feeds_groups)
          )
      end
    end

    it "returns feeds and feeds by groups when 'feeds' header is provided" do
      feed = create(:feed, :with_group)

      get("/fever", params: params(feeds: nil))

      groups = [{ group_id: feed.group_id, feed_ids: feed.id.to_s }]
      expect(response_as_object).to include(standard_answer)
        .and include(feeds: [feed.as_fever_json], feeds_groups: groups)
    end

    it "returns favicons hash when 'favicons' header provided" do
      get("/fever", params: params(favicons: nil))

      favicon = { id: 0, data: a_string_including("image/gif;base64") }
      expect(response_as_object).to include(standard_answer)
        .and include(favicons: [favicon])
    end

    it "returns stories when 'items' and 'since_id'" do
      create(:story, id: 5)
      story_two = create(:story, id: 6)

      get("/fever", params: params(items: nil, since_id: 5))

      expect(response_as_object).to include(standard_answer)
        .and include(items: [story_two.as_fever_json], total_items: 2)
    end

    it "returns stories when 'items' header is provided without 'since_id'" do
      stories = create_pair(:story)

      get("/fever", params: params(items: nil))

      expect(response_as_object).to include(standard_answer)
        .and include(items: stories.map(&:as_fever_json), total_items: 2)
    end

    it "returns stories ids when 'items' and 'with_ids'" do
      story = create(:story)

      get("/fever", params: params(items: nil, with_ids: story.id))

      expect(response_as_object).to include(standard_answer)
        .and include(items: [story.as_fever_json], total_items: 1)
    end

    it "returns links as empty array when 'links' header is provided" do
      get("/fever", params: params(links: nil))

      expect(response_as_object).to include(standard_answer)
        .and include(links: [])
    end

    it "returns unread items ids when 'unread_item_ids' header is provided" do
      stories = create_pair(:story)

      get("/fever", params: params(unread_item_ids: nil))

      expect(response_as_object).to include(standard_answer)
        .and include(unread_item_ids: stories.map(&:id).join(","))
    end

    it "returns starred items when 'saved_item_ids' header is provided" do
      stories = create_pair(:story, :starred)

      get("/fever", params: params(saved_item_ids: nil))

      expect(response_as_object).to include(standard_answer)
        .and include(saved_item_ids: stories.map(&:id).join(","))
    end
  end

  describe "#post" do
    it "commands to mark story as read" do
      story = create(:story)

      post("/fever", params: params(mark: "item", as: "read", id: story.id))

      expect(response_as_object).to include(standard_answer)
    end

    it "commands to mark story as unread" do
      story = create(:story, :read)

      post("/fever", params: params(mark: "item", as: "unread", id: story.id))

      expect(response_as_object).to include(standard_answer)
    end

    it "commands to save story" do
      story = create(:story)

      post("/fever", params: params(mark: "item", as: "saved", id: story.id))

      expect(response_as_object).to include(standard_answer)
    end

    it "commands to unsave story" do
      story = create(:story, :starred)

      post("/fever", params: params(mark: "item", as: "unsaved", id: story.id))

      expect(response_as_object).to include(standard_answer)
    end

    it "commands to mark group as read" do
      story = create(:story, :with_group, created_at: 1.week.ago)
      before = Time.zone.now.to_i
      id = story.feed.group_id

      post("/fever", params: params(mark: "group", as: "read", id:, before:))

      expect(response_as_object).to include(standard_answer)
    end

    it "commands to mark entire feed as read" do
      story = create(:story, created_at: 1.week.ago)
      before = Time.zone.now.to_i
      params = params(mark: "feed", as: "read", id: story.feed_id, before:)

      expect { post("/fever", params:) }
        .to change_record(story, :is_read).from(false).to(true)
    end

    describe "#index" do
      it "works with a trailing /" do
        story = create(:story, created_at: 1.week.ago)
        before = Time.zone.now.to_i
        params = params(mark: "feed", as: "read", id: story.feed_id, before:)

        expect { get("/fever/", params:) }
          .to change_record(story, :is_read).from(false).to(true)
      end
    end

    describe "#update" do
      it "works with a trailing /" do
        story = create(:story, created_at: 1.week.ago)
        before = Time.zone.now.to_i
        params = params(mark: "feed", as: "read", id: story.feed_id, before:)

        expect { post("/fever/", params:) }
          .to change_record(story, :is_read).from(false).to(true)
      end
    end
  end
end
