// @ts-nocheck
import { describe, it, expect, vi } from "vitest";

describe("Story", function () {
  it("should exist", function () {
    expect(Story).toBeDefined();
  });

  it("uses defaults", function () {
    var story = new Story();
    expect(story.get("open")).toBe(false);
    expect(story.get("selected")).toBe(false);
  });

  describe("open", function () {
    it("sets open and selected to true", function () {
      var story = new Story();
      story.open();
      expect(story.get("open")).toBe(true);
      expect(story.get("selected")).toBe(true);
    });

    it("sets is_read to true if keep_unread isn't true", function () {
      var story = new Story();
      expect(!!story.get("keep_unread")).toBe(false);
      story.open();
      expect(story.get("is_read")).toBe(true);
    });

    it("doesn't sets is_read to true if keep_unread is true", function () {
      var story = new Story();
      story.set("keep_unread", true);
      story.open();
      expect(!!story.get("is_read")).toBe(false);
    });

    it("calls closeOthers, unselectAll, setSelection on collection", function () {
      var story = new Story();
      var spy = (story.collection = {
        closeOthers: vi.fn(),
        unselectAll: vi.fn(),
        setSelection: vi.fn(),
      });
      story.open();
      expect(spy.closeOthers).toHaveBeenCalledWith(story);
      expect(spy.unselectAll).toHaveBeenCalledOnce();
      expect(spy.setSelection).toHaveBeenCalledWith(story);
    });

    it("calls save if it should save", function () {
      var story = new Story();

      vi.spyOn(story, "save").mockImplementation(function () {});
      vi.spyOn(story, "shouldSave").mockImplementation(function () {
        return true;
      });

      story.open();
      expect(story.shouldSave).toHaveBeenCalledOnce();
      expect(story.save).toHaveBeenCalledOnce();
    });
  });

  describe("close", function () {
    it("sets open to false", function () {
      var story = new Story();
      story.set("open", true);
      expect(story.get("open")).toBe(true);
      story.close();
      expect(story.get("open")).toBe(false);
    });
  });

  describe("select", function () {
    it("sets selected to true", function () {
      var story = new Story();
      story.select();
      expect(story.get("selected")).toBe(true);
    });

    it("calls unselectAll on collection", function () {
      var story = new Story();
      var spy = (story.collection = {
        unselectAll: vi.fn(),
      });
      story.select();
      expect(spy.unselectAll).toHaveBeenCalledOnce();
    });
  });

  describe("toggle", function () {
    it("calles open/close based on state", function () {
      var story = new Story();
      vi.spyOn(story, "open").mockImplementation(function () {});
      vi.spyOn(story, "close").mockImplementation(function () {});

      story.toggle();
      expect(story.open).toHaveBeenCalledOnce();
      expect(story.close).not.toHaveBeenCalled();

      story.set("open", true);
      story.toggle();
      expect(story.open).toHaveBeenCalledOnce();
      expect(story.close).toHaveBeenCalledOnce();
    });
  });

  describe("shouldSave", function () {
    it("returns false in there are no changed Attributes", function () {
      var story = new Story();
      vi.spyOn(story, "changedAttributes").mockImplementation(function () {
        return false;
      });
      expect(story.shouldSave()).toBe(false);
      expect(story.changedAttributes).toHaveBeenCalledOnce();
    });

    it("returns false if it has changedAttributes but no id", function () {
      var story = new Story();
      vi.spyOn(story, "changedAttributes").mockImplementation(function () {
        return { is_read: true };
      });
      expect(story.shouldSave()).toBe(false);
      expect(story.changedAttributes).toHaveBeenCalledOnce();
    });

    it("returns true if it has changedAttributes and an id", function () {
      var story = new Story({ id: 1 });
      vi.spyOn(story, "changedAttributes").mockImplementation(function () {
        return { is_read: true };
      });
      expect(story.shouldSave()).toBe(true);
      expect(story.changedAttributes).toHaveBeenCalledOnce();
    });
  });

  describe("openInTab", function () {
    it("opens a new window", function () {
      var story = new Story({ permalink: "http://localhost" });
      vi.spyOn(window, "open").mockImplementation(function () {});

      story.openInTab();
      expect(window.open).toHaveBeenCalledWith("http://localhost", "_blank");
    });
  });
});
