import { describe, it, expect, vi, beforeAll, beforeEach, afterEach } from "vitest";

describe("StoryView", function () {
  it("should exist", function () {
    expect(StoryView).toBeDefined();
  });

  describe("Rendering the view", function () {
    let story, view;

    beforeAll(function () {
      story = new Story({
        source: "TechKrunch",
        enclosure_url: null,
        headline: "Every startups acquired by Yahoo!",
        lead: "This is the lead.",
        title: "Every startups acquired by Yahoo! NOT!!",
        body: "All remote workers have been exiled to Ohio.",
        pretty_date: "Mon July 1, 2013",
        permalink: "http://example.com/krunch",
        keep_unread: false,
        is_read: false,
        is_starred: false,
      });

      view = new StoryView({ model: story });
      view.render();
    });

    it("should render li.story items", function () {
      expect(view.$el.hasClass("story")).toBe(true);
    });

    var assertTagExists = function (el, tagName, count) {
      count = typeof count !== "undefined" ? count : 1;
      expect(el.find(tagName)).toHaveLength(count);
    };

    var assertNoTagExists = function (el, tagName) {
      expect(el.find(tagName)).toHaveLength(0);
    };

    var assertPropertyRendered = function (el, model, propName) {
      expect(el.html()).toContain(model.get(propName));
    };

    it("should render blog title", function () {
      assertTagExists(view.$el, ".blog-title");
      assertPropertyRendered(view.$el, story, "source");
    });

    it("should render story headline", function () {
      assertTagExists(view.$el, ".story-title");
      assertPropertyRendered(view.$el, story, "headline");
    });

    it("should render story lead", function () {
      assertTagExists(view.$el, ".story-lead");
      assertPropertyRendered(view.$el, story, "lead");
    });

    it("should render story full title", function () {
      assertTagExists(view.$el, ".story-body");
      assertPropertyRendered(view.$el, story, "title");
    });

    it("should render story full title as link", function () {
      assertTagExists(view.$el, ".story-body h1 a");
    });

    it("should render story full body", function () {
      assertTagExists(view.$el, ".story-body");
      assertPropertyRendered(view.$el, story, "body");
    });

    it("should render story date", function () {
      assertTagExists(view.$el, ".story-published");
      assertPropertyRendered(view.$el, story, "pretty_date");
    });

    it("should render story permalink", function () {
      assertTagExists(view.$el, ".story-permalink");
      assertPropertyRendered(view.$el, story, "permalink");
    });

    it("should render keep as unread button", function () {
      assertTagExists(view.$el, ".story-keep-unread");
    });

    it("should autofill unread button based on item", function () {
      assertTagExists(view.$el, ".story-keep-unread .fa-square-o");

      story.set("keep_unread", true);
      view.render();

      assertTagExists(view.$el, ".story-keep-unread .fa-check");
    });

    it("should render two instances of the star button", function () {
      assertTagExists(view.$el, ".story-actions .story-starred");
      assertTagExists(view.$el, ".story-preview .story-starred");
    });

    it("should autofill star button based on item", function () {
      assertTagExists(view.$el, ".story-starred .fa-star-o", 2);

      story.set("is_starred", true);
      view.render();

      assertTagExists(view.$el, ".story-starred .fa-star", 2);
    });

    it("should not render enclosure link when not present", function () {
      assertNoTagExists(view.$el, ".story-enclosure");
    });

    it("should render enclosure link when present", function () {
      story.set("enclosure_url", "http://example.com/enclosure");
      view.render();

      assertTagExists(view.$el, ".story-enclosure");
      assertPropertyRendered(view.$el, story, "enclosure_url");
    });

    describe("Handling click on story", function () {
      let toggleStub;

      beforeEach(function () {
        toggleStub = vi.spyOn(story, "toggle").mockImplementation(function () {});
      });

      afterEach(function () {
        toggleStub.mockRestore();
      });

      it("should open story when clicked on it", function () {
        view.$(".story-preview").click();
        expect(toggleStub).toHaveBeenCalledOnce();
      });

      it("should not open story when clicked on it with metaKey pressed", function () {
        var e = jQuery.Event("click");
        e.metaKey = true;
        view.$(".story-preview").trigger(e);

        expect(toggleStub).not.toHaveBeenCalled();
      });

      it("should not open story when clicked on it with ctrlKey pressed", function () {
        var e = jQuery.Event("click");
        e.ctrlKey = true;
        view.$(".story-preview").trigger(e);

        expect(toggleStub).not.toHaveBeenCalled();
      });
    });
  });
});
